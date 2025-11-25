#!/usr/bin/env bash
# Git commit message generator - Single Claude call for speed
# Generates conventional commit with subject + body in one shot

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Config
COMMIT_MSG_FILE="${COMMIT_MSG_FILE:-/tmp/git-commit-msg-$$}"

# Ensure we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}" >&2
    exit 1
fi

# Get staged files or stage all if nothing staged
get_staged_files() {
    local staged_count
    staged_count=$(git diff --cached --name-only | wc -l | tr -d ' ')

    if [ "$staged_count" -eq 0 ]; then
        if [ "${NONINTERACTIVE:-0}" != "1" ]; then
            echo -e "${YELLOW}No staged changes. Staging all changes...${NC}" >&2
        fi
        git add -A 2>/dev/null
        staged_count=$(git diff --cached --name-only | wc -l | tr -d ' ')

        if [ "$staged_count" -eq 0 ]; then
            if [ "${NONINTERACTIVE:-0}" != "1" ]; then
                echo -e "${RED}No changes to commit${NC}" >&2
            fi
            exit 1
        fi
    fi

    echo "$staged_count"
}

# Generate complete commit message with single Claude call
generate_commit_message() {
    local file_status="$1"
    local diff_content="$2"

    # Check if claude CLI is available
    if ! command -v claude &> /dev/null; then
        echo "chore: update files"
        echo ""
        echo "    Updated functionality (claude CLI not installed)"
        return
    fi

    if [ "${NONINTERACTIVE:-0}" != "1" ]; then
        echo -e "${BLUE}Generating commit message...${NC}" >&2
    fi

    # Single prompt for complete commit message
    local prompt="Generate a conventional commit message for these changes.

FILES CHANGED:
\`\`\`
${file_status}
\`\`\`

DIFF:
\`\`\`
${diff_content}
\`\`\`

OUTPUT FORMAT (follow exactly):
type(scope): subject line (max 72 chars, lowercase, no period)

    Body paragraph explaining WHAT changed and WHY.
    - Bullet points for specific changes
    - Include file names, function names, values
    - Reference issues if applicable: Fixes #123, Part X/Y

TYPES: feat|fix|refactor|chore|test|docs|perf|style|ci|build
SCOPE: 1-2 words from paths (plugins, utils, config, api) or omit

EXAMPLES:

refactor(config): centralize model configuration (OCP)

    Create centralized model configuration following Open/Closed Principle:
    - New file: src/config/models.py with MODEL_CONFIG registry
    - 4 model profiles: generation, semantic, extraction, translation

    Benefits:
    - OCP: Models configurable without modifying source files
    - DRY: Single source of truth for model configuration

    Part 3/5 of Phase 1: SOLID refactoring

---

fix(auth): resolve token refresh race condition

    JWT refresh was failing when multiple requests triggered simultaneously.
    - Add mutex lock in refresh_token() to prevent concurrent refreshes
    - Cache refresh result for 100ms to dedupe rapid requests

    Fixes #42

---

feat(api): add batch processing endpoint

    New POST /api/batch for processing multiple items in single request.
    - src/routes/batch.py: BatchRequest model, validate_batch()
    - src/services/processor.py: process_batch() with chunking
    - Max 100 items per request, 30s timeout

OUTPUT ONLY THE COMMIT MESSAGE, no markdown fences or explanation:"

    # Single Claude call with timeout
    local result
    result=$(timeout 15s claude --print <<< "$prompt" 2>/dev/null) || true

    if [ -z "$result" ]; then
        # Fallback
        echo "chore: update files"
        echo ""
        echo "    Updated functionality"
    else
        # Clean up any markdown fences Claude might add
        echo "$result" | sed '/^```/d'
    fi
}

# Preview staged changes
preview_changes() {
    echo -e "${BLUE}=== Staged Changes ===${NC}"
    git diff --cached --name-status
    echo ""
    echo -e "${YELLOW}Press any key to continue or Ctrl-C to abort...${NC}"
    read -n 1 -s
}

# Preview commit message
preview_commit_message() {
    local msg_file="$1"
    echo ""
    echo -e "${GREEN}=== Commit Message Preview ===${NC}"
    echo -e "${BLUE}$(cat "$msg_file")${NC}"
    echo -e "${GREEN}==============================${NC}"
    echo ""
}

# Main workflow
main() {
    # Step 1: Get staged file count
    local file_count
    file_count=$(get_staged_files 2>/dev/null || echo "0")

    if [ "$file_count" -eq 0 ]; then
        if [ "${NONINTERACTIVE:-0}" != "1" ]; then
            echo -e "${RED}No changes to commit${NC}" >&2
        fi
        exit 1
    fi

    # Step 2: Preview if interactive
    if [ "${SKIP_PREVIEW:-0}" != "1" ] && [ "${NONINTERACTIVE:-0}" != "1" ]; then
        preview_changes
    fi

    # Step 3: Get git data
    local file_status diff_content
    file_status=$(git diff --cached --name-status)
    diff_content=$(git diff --cached)

    # Step 4: Truncate diff if too large
    local truncated_diff="$diff_content"
    if [ ${#diff_content} -gt 8000 ]; then
        truncated_diff="${diff_content:0:7500}

... (truncated, ${#diff_content} chars total)"
    fi

    # Step 5: Generate commit message (single Claude call)
    local commit_message
    commit_message=$(generate_commit_message "$file_status" "$truncated_diff")

    # Step 6: Output or commit
    if [ "${NONINTERACTIVE:-0}" = "1" ]; then
        echo "$commit_message"
        exit 0
    fi

    # Interactive mode: save and preview
    echo "$commit_message" > "$COMMIT_MSG_FILE"
    preview_commit_message "$COMMIT_MSG_FILE"

    # Confirm
    echo -e "${YELLOW}Options:${NC}"
    echo "  [c] Commit with this message"
    echo "  [e] Edit message"
    echo "  [a] Abort"
    echo ""
    read -rp "Choice (c/e/a): " choice

    case "$choice" in
        c|C)
            git commit -F "$COMMIT_MSG_FILE"
            echo -e "${GREEN}✓ Committed successfully${NC}"
            rm -f "$COMMIT_MSG_FILE"
            ;;
        e|E)
            ${EDITOR:-vim} "$COMMIT_MSG_FILE"
            git commit -F "$COMMIT_MSG_FILE"
            echo -e "${GREEN}✓ Committed successfully${NC}"
            rm -f "$COMMIT_MSG_FILE"
            ;;
        *)
            echo -e "${RED}Aborted${NC}"
            rm -f "$COMMIT_MSG_FILE"
            exit 1
            ;;
    esac
}

# Run
main "$@"
