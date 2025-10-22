#!/usr/bin/env bash
# Proper git commit: Bash for stats, AI for semantic understanding
# Bash does math, Claude Opus explains WHY

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Config
MAX_SUBJECT_LENGTH=72
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

# Get accurate git stats using bash
get_git_stats() {
    local stats_output=""

    # Get file counts by type
    local new_files modified_files deleted_files
    new_files=$(git diff --cached --name-status | grep -c "^A" || true)
    modified_files=$(git diff --cached --name-status | grep -c "^M" || true)
    deleted_files=$(git diff --cached --name-status | grep -c "^D" || true)

    # Total files
    local total_files=$((new_files + modified_files + deleted_files))

    # Get line stats
    local total_additions=0
    local total_deletions=0

    while IFS=$'\t' read -r add del file; do
        # Skip binary files (marked as -)
        if [[ "$add" != "-" ]]; then
            total_additions=$((total_additions + add))
        fi
        if [[ "$del" != "-" ]]; then
            total_deletions=$((total_deletions + del))
        fi
    done < <(git diff --cached --numstat)

    # Build stats summary with proper comma handling
    stats_output+="Files: $total_files"

    # Track if we've added any file type counts
    local has_details=false
    local detail_parts=()

    [ "$new_files" -gt 0 ] && detail_parts+=("$new_files new")
    [ "$modified_files" -gt 0 ] && detail_parts+=("$modified_files modified")
    [ "$deleted_files" -gt 0 ] && detail_parts+=("$deleted_files deleted")

    # Join with commas if we have details
    if [ ${#detail_parts[@]} -gt 0 ]; then
        stats_output+=" ("
        local first=true
        for part in "${detail_parts[@]}"; do
            if [ "$first" = true ]; then
                stats_output+="$part"
                first=false
            else
                stats_output+=", $part"
            fi
        done
        stats_output+=")"
    fi

    stats_output+="\nLines: +${total_additions}/-${total_deletions}"

    echo -e "$stats_output"
}

# Generate commit type and scope using fast LLM (Haiku)
generate_type_and_scope() {
    local file_status="$1"

    # Check if claude CLI is available
    if ! command -v claude &> /dev/null; then
        # Fallback to bash logic
        local new_count modified_count deleted_count
        new_count=$(echo "$file_status" | grep -c "^A" || true)
        modified_count=$(echo "$file_status" | grep -c "^M" || true)
        deleted_count=$(echo "$file_status" | grep -c "^D" || true)

        local type="chore"
        if [ "$new_count" -gt "$modified_count" ]; then
            type="feat"
        elif [ "$deleted_count" -gt 0 ] && [ "$deleted_count" -gt "$new_count" ]; then
            type="refactor"
        elif [ "$modified_count" -gt 0 ]; then
            type="fix"
        fi

        local scope=""
        if echo "$file_status" | grep -q "lua/plugins/"; then
            scope="plugins"
        elif echo "$file_status" | grep -q "lua/utils/"; then
            scope="utils"
        elif echo "$file_status" | grep -q "lua/"; then
            scope="config"
        fi

        echo "${type}(${scope})"
        return
    fi

    # LLM-based detection using Sonnet (fast, default model)
    local prompt="Determine conventional commit type and scope. Output ONLY: type(scope) or type

File changes:
\`\`\`
${file_status}
\`\`\`

Types: feat, fix, refactor, docs, style, test, chore, perf, build, ci
Scope: 1-2 words (plugins, utils, config, api, etc.) or empty

Rules:
- A (new) → feat
- M (modified) → fix or refactor
- D (deleted) → refactor or chore
- .md files → docs
- test files → test

Examples: feat(auth), fix(api), refactor, docs(readme)

Output ONLY the type(scope) or type, nothing else:"

    local result
    result=$(timeout 10s claude <<< "$prompt" 2>/dev/null | head -1 | tr -d '\n')

    if [ -z "$result" ]; then
        # Fallback
        echo "chore"
    else
        echo "$result"
    fi
}

# Generate subject line using LLM type/scope with dynamic verb
generate_subject() {
    local type_and_scope="$1"
    local file_count="$2"
    local file_status="$3"

    # type_and_scope is already "type(scope)" or "type" from LLM
    local subject="${type_and_scope}: "

    # Determine action verb based on file status
    local new_count modified_count deleted_count
    new_count=$(echo "$file_status" | grep -c "^A" || true)
    modified_count=$(echo "$file_status" | grep -c "^M" || true)
    deleted_count=$(echo "$file_status" | grep -c "^D" || true)

    local verb="update"
    if [ "$deleted_count" -gt 0 ] && [ "$new_count" -eq 0 ] && [ "$modified_count" -eq 0 ]; then
        verb="delete"
    elif [ "$new_count" -gt 0 ] && [ "$deleted_count" -eq 0 ] && [ "$modified_count" -eq 0 ]; then
        verb="add"
    elif [ "$modified_count" -gt 0 ] && [ "$new_count" -eq 0 ] && [ "$deleted_count" -eq 0 ]; then
        verb="update"
    else
        # Mixed operations - use update
        verb="update"
    fi

    # Build subject with proper pluralization
    if [ "$file_count" -eq 1 ]; then
        subject+="${verb} 1 file"
    else
        subject+="${verb} ${file_count} files"
    fi

    # Truncate if needed
    if [ ${#subject} -gt "$MAX_SUBJECT_LENGTH" ]; then
        subject="${subject:0:$((MAX_SUBJECT_LENGTH-3))}..."
    fi

    echo "$subject"
}

# Generate AI description using Claude Opus
generate_ai_description() {
    local diff_content="$1"

    # Check if claude CLI is available
    if ! command -v claude &> /dev/null; then
        echo "No AI description available (claude CLI not installed)"
        return
    fi

    if [ "${NONINTERACTIVE:-0}" != "1" ]; then
        echo -e "${BLUE}Analyzing changes with Claude Opus...${NC}" >&2
    fi

    # Engineer shorthand: Facts only, maximum density
    local prompt="Write commit body in engineer shorthand. Pure facts, zero prose.

Style: Telegram-terse. Name everything. Show all transitions.

MANDATORY:
- Specific names: file.lua, function_name(), var_name, ClassName
- All values/numbers: 645 lines, 300ms, 16 rounds, v1.2.3
- Transitions: X→Y, A to B, old_name → new_name
- Actions: deletes, adds, moves, changes, replaces
- NO descriptive verbs: removes/eliminates/refactors are OK, but NO 'improves/enhances/optimizes'
- NO explanations/rationale (unless critical security/bug)

Format: 2-3 ultra-short sentences. Think: git notes, not documentation.

Examples:

❌ 'Improves authentication by updating the hashing algorithm to be more secure'
✅ 'bcrypt→Argon2id. Work factor: 10→16. CVE-2023-1234.'

❌ 'Optimizes database queries by adding an index'
✅ 'Index: (user_id, created_at) on users. Query: 2.3s→45ms.'

❌ 'Updates error handling with retry logic'
✅ 'DB ops: try-catch + exponential backoff (max 3×). 500→503 on unavailable.'

❌ 'Refactors commit message generation to use bash'
✅ 'Deletes lua/utils/ai-commit.lua (645 lines). git-commit-auto.lua: 300ms→150ms. Autocmd: ftplugin→polish.lua.'

❌ 'Centralizes auto-generation to single implementation'
✅ 'ai-commit/ module deleted. git-commit-auto.lua calls git-commit-ai.sh. ftplugin: formatting only.'

Git diff:
\`\`\`
${diff_content}
\`\`\`

Output 2-3 sentences (telegram style):"

    # Call Claude with -p flag for Opus (longer timeout for detailed analysis)
    local description
    description=$(timeout 25s claude -p <<< "$prompt" 2>/dev/null | head -100)

    if [ -z "$description" ]; then
        echo "Added/updated functionality and documentation"
    else
        echo "$description"
    fi
}

# Build complete commit message
build_commit_message() {
    local subject="$1"
    local description="$2"
    local stats="$3"

    # Format: subject + blank line + description + blank line + stats
    cat <<EOF
$subject

$description

$stats
EOF
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

    # Step 3: Get git data (bash - accurate)
    local file_status diff_content
    file_status=$(git diff --cached --name-status)
    diff_content=$(git diff --cached)

    # Step 4: Calculate stats (bash - deterministic)
    local stats
    stats=$(get_git_stats)

    # Step 5: Truncate diff if too large (Claude has token limits)
    local truncated_diff="$diff_content"
    if [ ${#diff_content} -gt 10000 ]; then
        truncated_diff="${diff_content:0:9500}"
        truncated_diff="$truncated_diff

... (diff truncated at 9500 chars, total size: ${#diff_content} chars)"
    fi

    # Step 6: Run LLM calls in PARALLEL for speed
    if [ "${NONINTERACTIVE:-0}" != "1" ]; then
        echo -e "${BLUE}Generating commit message (parallel: type/scope + body)...${NC}" >&2
    fi

    # Temp files for parallel execution
    local type_scope_file="/tmp/git-commit-type-$$"
    local body_file="/tmp/git-commit-body-$$"

    # Run both LLM calls in parallel using temp files
    {
        generate_type_and_scope "$file_status" > "$type_scope_file" 2>/dev/null || echo "chore" > "$type_scope_file"
    } &
    local pid_type=$!

    {
        generate_ai_description "$truncated_diff" > "$body_file" 2>/dev/null || echo "Added/updated functionality" > "$body_file"
    } &
    local pid_body=$!

    # Wait for both to complete
    wait $pid_type $pid_body

    # Read results
    local type_and_scope
    type_and_scope=$(cat "$type_scope_file" 2>/dev/null | head -1 | tr -d '\n' || echo "chore")

    # Read description and strip markdown code blocks if present
    local description
    description=$(cat "$body_file" 2>/dev/null || echo "Added/updated functionality")
    # Remove leading/trailing code block markers
    description=$(echo "$description" | sed '/^```$/d' | sed 's/^```.*$//' | sed '/^$/d' | head -10)

    # Fallback if empty after stripping
    if [ -z "$description" ]; then
        description="Added/updated functionality"
    fi

    # Add newlines after sentences (after ". " or ". " at end)
    description=$(echo "$description" | sed 's/\. /.\n/g' | sed 's/\.$/.\n/')

    # Cleanup temp files
    rm -f "$type_scope_file" "$body_file"

    # Step 7: Generate subject line from LLM type/scope with file_status for verb
    local subject
    subject=$(generate_subject "$type_and_scope" "$file_count" "$file_status")

    # Step 8: Build complete message
    local commit_message
    commit_message=$(build_commit_message "$subject" "$description" "$stats")

    # Step 9: Output or commit
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
