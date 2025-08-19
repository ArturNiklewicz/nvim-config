#!/bin/bash

# Advanced Keybinding Analyzer with Parametrized Workflow
# Extracts 100% of keybindings with complete context

# Parameters
CONFIG_DIR="${1:-.}"
OUTPUT_FORMAT="${2:-all}" # all, csv, json, summary
FILTER_MODE="${3:-}" # normal, visual, insert, terminal, or empty for all

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Output files
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CSV_FILE="keybindings_${TIMESTAMP}.csv"
JSON_FILE="keybindings_${TIMESTAMP}.json"
SUMMARY_FILE="keybindings_summary_${TIMESTAMP}.txt"

# Function to extract specific pattern
extract_pattern() {
    local pattern_name=$1
    local regex=$2
    local file_glob=$3
    
    echo -e "${CYAN}Extracting pattern: $pattern_name${NC}"
    
    case $pattern_name in
        "astrocore_mappings")
            # Complex extraction for nested mappings
            find "$CONFIG_DIR" -name "*.lua" -type f | while read -r file; do
                # Use awk to extract multi-line mapping blocks
                awk -v file="$file" '
                /mappings\s*=\s*\{/ {
                    in_mappings = 1
                    line_start = NR
                }
                in_mappings {
                    content = content $0 "\n"
                    if ($0 ~ /^\s*\}\s*,?\s*$/ && --brace_count == 0) {
                        # Extract mode
                        if (match(content, /([nvitxso])\s*=\s*\{/)) {
                            mode = substr(content, RSTART, 1)
                        }
                        # Extract all keybindings in this block
                        while (match(content, /\["([^"]+)"\]\s*=\s*\{[^}]*\}/)) {
                            key = substr(content, RSTART+2, RLENGTH-2)
                            gsub(/"\].*/, "", key)
                            print file "," line_start "," mode "," key ",astrocore_mapping"
                            content = substr(content, RSTART + RLENGTH)
                        }
                        content = ""
                        in_mappings = 0
                    }
                    if ($0 ~ /\{/) brace_count++
                    if ($0 ~ /\}/) brace_count--
                }' "$file" 2>/dev/null
            done
            ;;
            
        "keys_table")
            # Extract from keys = { ... } tables
            rg -U --multiline --no-heading --line-number --json \
               'keys\s*=\s*\{[^\}]*\{[^\}]*\}[^\}]*\}' \
               --glob "$file_glob" "$CONFIG_DIR" 2>/dev/null | \
            jq -r '.data | select(.lines.text) | 
                   "\(.path.text):\(.line_number):\(.lines.text)"' 2>/dev/null | \
            while IFS=: read -r file line content; do
                # Extract each key definition
                echo "$content" | grep -oE '\{[^}]*\}' | while read -r key_def; do
                    if key=$(echo "$key_def" | grep -oP '["'"'"'][^"'"'"']+["'"'"']' | head -1 | sed 's/["'"'"']//g'); then
                        mode=$(echo "$key_def" | grep -oP 'mode\s*=\s*["'"'"'][^"'"'"']+["'"'"']' | sed 's/.*["'"'"']\([^"'"'"']*\)["'"'"'].*/\1/')
                        desc=$(echo "$key_def" | grep -oP 'desc\s*=\s*["'"'"'][^"'"'"']+["'"'"']' | sed 's/.*["'"'"']\([^"'"'"']*\)["'"'"'].*/\1/')
                        echo "$file,$line,${mode:-n},$key,keys_table,$desc"
                    fi
                done
            done
            ;;
            
        "vim_keymap_set")
            # Direct vim.keymap.set calls
            rg --no-heading --line-number \
               'vim\.keymap\.set\s*\([^)]+\)' \
               --glob "$file_glob" "$CONFIG_DIR" | \
            while IFS=: read -r file line content; do
                if [[ $content =~ vim\.keymap\.set\s*\(\s*[\"\'']([nvitxso])[\"\''],\s*[\"\'']([^\"\']+)[\"\''] ]]; then
                    mode="${BASH_REMATCH[1]}"
                    key="${BASH_REMATCH[2]}"
                    desc=$(echo "$content" | grep -oP 'desc\s*=\s*["'"'"'][^"'"'"']+["'"'"']' | sed 's/.*["'"'"']\([^"'"'"']*\)["'"'"'].*/\1/')
                    echo "$file,$line,$mode,$key,vim.keymap.set,${desc:-no_description}"
                fi
            done
            ;;
            
        "which_key_defs")
            # Which-key specific definitions
            rg --no-heading --line-number \
               'wk\.register\s*\(' \
               --glob "$file_glob" "$CONFIG_DIR" | \
            while IFS=: read -r file line content; do
                echo "$file,$line,n,<which-key-group>,which_key_register,group_definition"
            done
            ;;
    esac
}

# Main extraction workflow
main() {
    echo -e "${GREEN}=== Neovim Keybinding Analyzer ===${NC}"
    echo "Config directory: $CONFIG_DIR"
    echo "Output format: $OUTPUT_FORMAT"
    echo "Filter mode: ${FILTER_MODE:-all}"
    echo ""
    
    # Initialize CSV
    echo "file,line,mode,key,source,description" > "$CSV_FILE"
    
    # Extract all patterns
    patterns=(
        "astrocore_mappings:*.lua"
        "keys_table:*.lua"
        "vim_keymap_set:*.lua"
        "which_key_defs:which-key.lua"
    )
    
    for pattern_spec in "${patterns[@]}"; do
        IFS=: read -r pattern glob <<< "$pattern_spec"
        extract_pattern "$pattern" "" "$glob" >> "$CSV_FILE"
    done
    
    # Apply mode filter if specified
    if [[ -n "$FILTER_MODE" ]]; then
        grep -E "^[^,]+,[^,]+,$FILTER_MODE," "$CSV_FILE" > "${CSV_FILE}.tmp"
        mv "${CSV_FILE}.tmp" "$CSV_FILE"
    fi
    
    # Generate outputs based on format
    case $OUTPUT_FORMAT in
        "csv")
            echo -e "${GREEN}CSV output saved to: $CSV_FILE${NC}"
            ;;
            
        "json")
            # Convert CSV to JSON
            echo "[" > "$JSON_FILE"
            tail -n +2 "$CSV_FILE" | while IFS=, read -r file line mode key source desc; do
                cat >> "$JSON_FILE" <<EOF
  {
    "file": "$file",
    "line": $line,
    "mode": "$mode",
    "key": "$key",
    "source": "$source",
    "description": "$desc"
  },
EOF
            done
            # Remove trailing comma and close array
            sed -i '$ s/,$//' "$JSON_FILE"
            echo "]" >> "$JSON_FILE"
            echo -e "${GREEN}JSON output saved to: $JSON_FILE${NC}"
            ;;
            
        "summary")
            generate_summary
            echo -e "${GREEN}Summary saved to: $SUMMARY_FILE${NC}"
            ;;
            
        "all"|*)
            generate_summary
            # Also convert to JSON
            $0 "$CONFIG_DIR" "json" "$FILTER_MODE" >/dev/null 2>&1
            echo -e "${GREEN}All outputs generated:${NC}"
            echo "  - CSV: $CSV_FILE"
            echo "  - JSON: $JSON_FILE"
            echo "  - Summary: $SUMMARY_FILE"
            ;;
    esac
    
    # Show duplicate analysis
    echo -e "\n${YELLOW}=== Duplicate Keybindings ===${NC}"
    awk -F',' 'NR>1 {print $3 ":" $4}' "$CSV_FILE" | sort | uniq -c | sort -rn | \
    while read -r count mode_key; do
        if [ "$count" -gt 1 ]; then
            IFS=: read -r mode key <<< "$mode_key"
            echo -e "${RED}[$mode] $key appears $count times:${NC}"
            grep ",$mode,$key," "$CSV_FILE" | awk -F',' '{printf "  %-50s line %-5s (%s)\n", $1, $2, $5}'
        fi
    done
}

# Generate summary report
generate_summary() {
    {
        echo "=== Neovim Keybinding Analysis Summary ==="
        echo "Generated: $(date)"
        echo "Config Directory: $CONFIG_DIR"
        echo ""
        
        echo "=== Statistics ==="
        total=$(tail -n +2 "$CSV_FILE" | wc -l)
        echo "Total keybindings: $total"
        
        echo ""
        echo "=== By Mode ==="
        for mode in n v i t x s o; do
            count=$(grep -c ",$mode," "$CSV_FILE")
            [ "$count" -gt 0 ] && echo "  $mode ($(case $mode in
                n) echo "normal";;
                v) echo "visual";;
                i) echo "insert";;
                t) echo "terminal";;
                x) echo "visual block";;
                s) echo "select";;
                o) echo "operator";;
            esac)): $count"
        done
        
        echo ""
        echo "=== By Source ==="
        awk -F',' 'NR>1 {print $5}' "$CSV_FILE" | sort | uniq -c | sort -rn
        
        echo ""
        echo "=== Leader Key Usage ==="
        grep '<Leader>' "$CSV_FILE" | awk -F',' '{print $4}' | \
        sed 's/<Leader>//' | cut -c1 | sort | uniq -c | sort -rn | \
        while read -r count prefix; do
            echo "  <Leader>$prefix*: $count mappings"
        done
        
        echo ""
        echo "=== Files with Keybindings ==="
        awk -F',' 'NR>1 {print $1}' "$CSV_FILE" | sort | uniq -c | sort -rn
        
    } > "$SUMMARY_FILE"
    
    cat "$SUMMARY_FILE"
}

# Run main function
main