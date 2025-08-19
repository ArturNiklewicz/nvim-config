#!/bin/bash

echo "=== SEARCHING FOR ALL KEYBINDINGS IN NVIM CONFIG ==="
echo

# Temporary file to store all keybindings
temp_file="/tmp/nvim_keybindings_$$.txt"

# Find all keybindings in lua files
find . -name "*.lua" -type f | while read file; do
    # Pattern 1: ["<key>"] = { ... }
    grep -n '\["[^"]*"\]\s*=' "$file" | while read -r line; do
        line_num=$(echo "$line" | cut -d: -f1)
        key=$(echo "$line" | grep -o '\["[^"]*"\]' | sed 's/\["//;s/"\]//')
        echo "n:$key|$file:$line_num" >> "$temp_file"
    done
    
    # Pattern 2: vim.keymap.set("mode", "key", ...)
    grep -n 'vim\.keymap\.set' "$file" | while read -r line; do
        line_num=$(echo "$line" | cut -d: -f1)
        # Extract mode and key
        mode=$(echo "$line" | sed -n 's/.*vim\.keymap\.set(\s*["\x27]\([^"\x27]*\)["\x27].*/\1/p')
        key=$(echo "$line" | sed -n 's/.*vim\.keymap\.set([^,]*,\s*["\x27]\([^"\x27]*\)["\x27].*/\1/p')
        if [ -n "$mode" ] && [ -n "$key" ]; then
            echo "$mode:$key|$file:$line_num" >> "$temp_file"
        fi
    done
done

# Sort and find duplicates
echo "=== DUPLICATE KEYBINDINGS ==="
echo
sort "$temp_file" | uniq -c | grep -v '^ *1 ' | while read count binding; do
    key=$(echo "$binding" | cut -d'|' -f1)
    echo "Duplicate key: $key (found $count times)"
    grep "^$key|" "$temp_file" | cut -d'|' -f2 | sed 's/^/  - /'
    echo
done

# Count statistics
total_bindings=$(wc -l < "$temp_file")
unique_bindings=$(cut -d'|' -f1 "$temp_file" | sort -u | wc -l)
duplicate_keys=$(sort "$temp_file" | uniq -c | grep -v '^ *1 ' | wc -l)

echo "=== SUMMARY ==="
echo "Total keybinding definitions: $total_bindings"
echo "Unique keybindings: $unique_bindings"
echo "Duplicate keybindings: $duplicate_keys"

# Clean up
rm -f "$temp_file"