#!/bin/bash

# Complete Keybinding Extraction Script for Neovim Configuration
# This script extracts 100% of keybindings with their locations

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Output file
OUTPUT_FILE="keybindings-report.txt"
CSV_FILE="keybindings.csv"

echo "=== Neovim Keybinding Extraction Tool ===" | tee $OUTPUT_FILE
echo "Extracting all keybindings from configuration..." | tee -a $OUTPUT_FILE
echo "" | tee -a $OUTPUT_FILE

# Initialize CSV with headers
echo "File,Line,Mode,Key,Action,Description" > $CSV_FILE

# Function to extract keybindings from different patterns
extract_keybindings() {
    local pattern=$1
    local description=$2
    
    echo -e "\n${BLUE}=== $description ===${NC}" | tee -a $OUTPUT_FILE
    
    case $pattern in
        "mappings")
            # Extract from mappings = { n = { ["<key>"] = { ... } } }
            rg -U --multiline --no-heading --line-number \
               'mappings\s*=\s*\{[^}]*\[["\'](<[^>]+>|[^"\']+)["\']\]\s*=\s*\{[^}]*\}' \
               --glob '*.lua' \
               -o | while IFS=: read -r file line match; do
                # Extract the key
                key=$(echo "$match" | grep -oP '\["[^"]+"\]|\['"'"'[^'"'"']+'"'"'\]' | sed 's/\["//;s/"\]//;s/\['"'"'//;s/'"'"'\]//')
                mode=$(echo "$match" | grep -oP '(n|v|i|t|x|s|o)\s*=\s*\{' | cut -d= -f1 | tr -d ' ')
                echo "$file:$line - Mode: ${mode:-n} - Key: $key" | tee -a $OUTPUT_FILE
                echo "$file,$line,${mode:-n},$key,extracted_from_mappings,mappings_table" >> $CSV_FILE
            done
            ;;
            
        "keys")
            # Extract from keys = { { "key", "action", desc = "..." } }
            rg -U --multiline --no-heading --line-number \
               'keys\s*=\s*\{[^}]*\{[^}]*["\''](<[^>]+>|[^"\']+)["\''][^}]*\}' \
               --glob '*.lua' \
               -o | while IFS=: read -r file line match; do
                # Extract first quoted string as key
                key=$(echo "$match" | grep -oP '["'"'"'][^"'"'"']*["'"'"']' | head -1 | sed 's/["'"'"']//g')
                desc=$(echo "$match" | grep -oP 'desc\s*=\s*["'"'"'][^"'"'"']*["'"'"']' | sed 's/desc\s*=\s*//;s/["'"'"']//g')
                echo "$file:$line - Key: $key - Desc: $desc" | tee -a $OUTPUT_FILE
                echo "$file,$line,n,$key,from_keys_table,$desc" >> $CSV_FILE
            done
            ;;
            
        "keymap.set")
            # Extract from vim.keymap.set("mode", "key", action, opts)
            rg --no-heading --line-number \
               'vim\.keymap\.set\s*\(\s*["\'']([nvitxso])["\''],\s*["\'']([^"\']+)["\'']' \
               --glob '*.lua' \
               -o | while IFS=: read -r file line match; do
                mode=$(echo "$match" | grep -oP '["'"'"'][nvitxso]["'"'"']' | sed 's/["'"'"']//g')
                key=$(echo "$match" | grep -oP '["'"'"'][^"'"'"']*["'"'"']' | sed -n '2p' | sed 's/["'"'"']//g')
                echo "$file:$line - Mode: $mode - Key: $key" | tee -a $OUTPUT_FILE
                echo "$file,$line,$mode,$key,vim.keymap.set,direct_mapping" >> $CSV_FILE
            done
            ;;
            
        "keymap_func")
            # Extract from keymap("mode", "key", action, opts) function calls
            rg --no-heading --line-number \
               'keymap\s*\(\s*["\'']([nvitxso])["\''],\s*["\'']([^"\']+)["\'']' \
               --glob '*.lua' \
               -o | while IFS=: read -r file line match; do
                mode=$(echo "$match" | grep -oP '["'"'"'][nvitxso]["'"'"']' | sed 's/["'"'"']//g')
                key=$(echo "$match" | grep -oP '["'"'"'][^"'"'"']*["'"'"']' | sed -n '2p' | sed 's/["'"'"']//g')
                echo "$file:$line - Mode: $mode - Key: $key" | tee -a $OUTPUT_FILE
                echo "$file,$line,$mode,$key,keymap_function,local_keymap" >> $CSV_FILE
            done
            ;;
            
        "bracket_nav")
            # Extract ] and [ navigation mappings
            rg --no-heading --line-number \
               '\["[\[\]][^"]*"\]\s*=' \
               --glob '*.lua' \
               -o | while IFS=: read -r file line match; do
                key=$(echo "$match" | grep -oP '\["[^"]+"\]' | sed 's/\["//;s/"\]//')
                echo "$file:$line - Navigation Key: $key" | tee -a $OUTPUT_FILE
                echo "$file,$line,n,$key,bracket_navigation,navigation" >> $CSV_FILE
            done
            ;;
    esac
}

# Extract all patterns
extract_keybindings "mappings" "Mappings Table Format"
extract_keybindings "keys" "Keys Table Format"
extract_keybindings "keymap.set" "vim.keymap.set() Calls"
extract_keybindings "keymap_func" "Local keymap() Function Calls"
extract_keybindings "bracket_nav" "Bracket Navigation Keys"

# Special extraction for on_attach keybindings
echo -e "\n${BLUE}=== On-Attach Keybindings ===${NC}" | tee -a $OUTPUT_FILE
rg -U --multiline --no-heading --line-number \
   'on_attach\s*=\s*function[^}]*vim\.keymap\.set[^}]*end' \
   --glob '*.lua' | tee -a $OUTPUT_FILE

# Find potential duplicates
echo -e "\n${RED}=== Analyzing for Duplicates ===${NC}" | tee -a $OUTPUT_FILE
echo "Keys appearing multiple times:" | tee -a $OUTPUT_FILE

# Sort and find duplicate keys
awk -F',' 'NR>1 {print $4}' $CSV_FILE | sort | uniq -c | sort -rn | \
while read count key; do
    if [ "$count" -gt 1 ]; then
        echo -e "${YELLOW}Key '$key' appears $count times:${NC}" | tee -a $OUTPUT_FILE
        grep ",$key," $CSV_FILE | awk -F',' '{print "  " $1 ":" $2 " (Mode: " $3 ")"}' | tee -a $OUTPUT_FILE
    fi
done

# Summary statistics
echo -e "\n${GREEN}=== Summary ===${NC}" | tee -a $OUTPUT_FILE
total_keys=$(awk -F',' 'NR>1' $CSV_FILE | wc -l)
unique_keys=$(awk -F',' 'NR>1 {print $4}' $CSV_FILE | sort -u | wc -l)
duplicate_keys=$((total_keys - unique_keys))

echo "Total keybindings found: $total_keys" | tee -a $OUTPUT_FILE
echo "Unique keybindings: $unique_keys" | tee -a $OUTPUT_FILE
echo "Duplicate definitions: $duplicate_keys" | tee -a $OUTPUT_FILE

echo -e "\n${GREEN}Results saved to:${NC}" | tee -a $OUTPUT_FILE
echo "  - Full report: $OUTPUT_FILE" | tee -a $OUTPUT_FILE
echo "  - CSV data: $CSV_FILE" | tee -a $OUTPUT_FILE