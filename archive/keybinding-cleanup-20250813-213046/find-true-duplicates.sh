#!/bin/bash

echo "=== FINDING TRUE DUPLICATE KEYBINDINGS IN ACTIVE PLUGINS ==="
echo

# Focus only on the main astrocore.lua file and other active plugins
active_plugins=(
    "./lua/plugins/astrocore.lua"
    "./lua/plugins/vscode-editing.lua"
    "./lua/plugins/molten.lua"
    "./lua/plugins/markdown-preview.lua"
    "./lua/plugins/claudecode.lua"
    "./lua/plugins/fugitive.lua"
    "./lua/plugins/gitsigns.lua"
    "./lua/plugins/error-messages.lua"
    "./lua/plugins/keybind-help.lua"
    "./lua/plugins/which-key.lua"
    "./lua/plugins/neo-tree.lua"
)

temp_file="/tmp/keybindings_$$.txt"

# Extract keybindings from active plugins only
for file in "${active_plugins[@]}"; do
    if [ -f "$file" ]; then
        # Extract from mappings tables: ["<key>"] = { ... }
        grep -n '\["<[^"]*>"\]\s*=' "$file" 2>/dev/null | while read -r line; do
            line_num=$(echo "$line" | cut -d: -f1)
            key=$(echo "$line" | grep -o '\["[^"]*"\]' | sed 's/\["//;s/"\]//')
            # Try to determine mode from context
            mode_context=$(grep -B10 "^$line" "$file" 2>/dev/null | tail -10)
            mode="n"  # default
            if echo "$mode_context" | grep -q "mappings.*=.*{.*v\s*="; then
                mode="v"
            elif echo "$mode_context" | grep -q "mappings.*=.*{.*i\s*="; then
                mode="i"
            elif echo "$mode_context" | grep -q "mappings.*=.*{.*t\s*="; then
                mode="t"
            fi
            echo "$mode:$key|$file:$line_num" >> "$temp_file"
        done
        
        # Extract vim.keymap.set calls
        grep -n 'vim\.keymap\.set' "$file" 2>/dev/null | while read -r line; do
            line_num=$(echo "$line" | cut -d: -f1)
            # Extract mode and key
            full_line=$(echo "$line" | cut -d: -f2-)
            mode=$(echo "$full_line" | sed -n 's/.*vim\.keymap\.set(\s*["'\'']\([^"'\'']*\)["'\''].*/\1/p')
            key=$(echo "$full_line" | sed -n 's/.*vim\.keymap\.set([^,]*,\s*["'\'']\([^"'\'']*\)["'\''].*/\1/p')
            if [ -n "$mode" ] && [ -n "$key" ]; then
                echo "$mode:$key|$file:$line_num" >> "$temp_file"
            fi
        done
    fi
done

# Find duplicates
echo "=== DUPLICATE KEYBINDINGS IN ACTIVE PLUGINS ==="
echo
sort "$temp_file" | uniq -c | sort -rn | grep -v '^ *1 ' | while read count binding; do
    key=$(echo "$binding" | cut -d'|' -f1)
    mode=$(echo "$key" | cut -d: -f1)
    keyseq=$(echo "$key" | cut -d: -f2)
    echo "[$mode] $keyseq - Defined $count times:"
    grep "^$key|" "$temp_file" | cut -d'|' -f2 | while read location; do
        file=$(echo "$location" | cut -d: -f1)
        line=$(echo "$location" | cut -d: -f2)
        echo "  - $file:$line"
        # Show the actual line content
        if [ -f "$file" ]; then
            content=$(sed -n "${line}p" "$file" | sed 's/^/    /')
            echo "$content"
        fi
    done
    echo
done

# Summary
total=$(wc -l < "$temp_file" 2>/dev/null || echo 0)
unique=$(cut -d'|' -f1 "$temp_file" | sort -u | wc -l 2>/dev/null || echo 0)
duplicates=$(sort "$temp_file" | uniq -c | grep -v '^ *1 ' | wc -l 2>/dev/null || echo 0)

echo "=== SUMMARY ==="
echo "Total keybinding definitions: $total"
echo "Unique keybindings: $unique"
echo "Keybindings with duplicates: $duplicates"

# Clean up
rm -f "$temp_file"