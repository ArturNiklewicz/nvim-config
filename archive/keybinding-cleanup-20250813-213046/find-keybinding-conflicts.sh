#!/bin/bash

echo "=== ANALYZING KEYBINDINGS FOR CONFLICTS ==="
echo

# Temporary files
all_bindings="/tmp/all_bindings_$$.txt"
sorted_bindings="/tmp/sorted_bindings_$$.txt"

# Extract keybindings from all lua files
find . -name "*.lua" -type f | while read file; do
    # Skip test files and analyzer scripts
    if [[ "$file" == *"test"* ]] || [[ "$file" == *"keybinding-"* ]] || [[ "$file" == *"extract-"* ]]; then
        continue
    fi
    
    # Pattern 1: ["<key>"] = { ... } in mappings tables
    grep -n '\["<[^"]*>"\]\s*=' "$file" | while read -r line; do
        line_num=$(echo "$line" | cut -d: -f1)
        key=$(echo "$line" | grep -o '\["[^"]*"\]' | sed 's/\["//;s/"\]//')
        # Try to determine mode from context (look for n = { or similar)
        mode="n"  # default to normal mode
        echo "$mode|$key|$file:$line_num" >> "$all_bindings"
    done
    
    # Pattern 2: vim.keymap.set calls
    grep -n 'vim\.keymap\.set' "$file" | while read -r line; do
        line_num=$(echo "$line" | cut -d: -f1)
        # More careful extraction
        if echo "$line" | grep -q 'vim\.keymap\.set('; then
            # Extract mode and key more carefully
            mode=$(echo "$line" | sed -n 's/.*vim\.keymap\.set(\s*["'\'']\([^"'\'']*\)["'\''].*/\1/p')
            key=$(echo "$line" | sed -n 's/.*vim\.keymap\.set([^,]*,\s*["'\'']\([^"'\'']*\)["'\''].*/\1/p')
            if [ -n "$mode" ] && [ -n "$key" ]; then
                echo "$mode|$key|$file:$line_num" >> "$all_bindings"
            fi
        fi
    done
done

# Sort bindings
sort "$all_bindings" > "$sorted_bindings"

# Find exact duplicates (same mode and key)
echo "=== EXACT DUPLICATE KEYBINDINGS (same mode + key) ==="
echo
awk -F'|' '{key=$1"|"$2; count[key]++; lines[key]=lines[key]"\n  "$3} END {for (k in count) if (count[k]>1) print k" (defined "count[k]" times):"lines[k]"\n"}' "$sorted_bindings" | sort

# Find potential conflicts (same key, different modes)
echo -e "\n=== POTENTIAL CONFLICTS (same key in different modes) ==="
echo
awk -F'|' '{key=$2; modes[key]=modes[key]" "$1; files[key]=files[key]"\n  ["$1"] "$3} END {for (k in modes) {split(modes[k], m, " "); if (length(m)>2) print k":"files[k]"\n"}}' "$sorted_bindings" | sort

# Show summary of keybindings by mode
echo -e "\n=== KEYBINDING SUMMARY BY MODE ==="
awk -F'|' '{count[$1]++} END {for (mode in count) print mode": "count[mode]" bindings"}' "$sorted_bindings" | sort

# Clean up
rm -f "$all_bindings" "$sorted_bindings"