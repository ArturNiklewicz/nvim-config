#!/bin/bash

echo "=== ANALYZING KEYBINDINGS IN NVIM CONFIG ==="
echo

# Find all keybinding patterns in active plugin files
echo "=== DUPLICATE KEYBINDINGS ACROSS FILES ==="
echo

# First, let's identify which astrocore files are actually being loaded
echo "Checking astrocore files in plugins directory:"
ls -la lua/plugins/astrocore*.lua
echo

# Extract keybindings from all lua files
echo "Extracting all keybindings..."
temp_file="/tmp/nvim_keybindings.txt"

# Clear temp file
> "$temp_file"

# Find keybinding patterns in all lua files
for file in lua/plugins/*.lua; do
    # Skip backup files
    if [[ "$file" == *.bak ]]; then
        continue
    fi
    
    # Extract ["<key>"] = { patterns
    grep -o '\["<[^"]*>"\]' "$file" 2>/dev/null | while read binding; do
        echo "$binding|$file" >> "$temp_file"
    done
done

# Find duplicates
echo "=== KEYBINDINGS DEFINED IN MULTIPLE FILES ==="
cat "$temp_file" | cut -d'|' -f1 | sort | uniq -d | while read dup_binding; do
    echo
    echo "Duplicate: $dup_binding"
    grep "^${dup_binding}|" "$temp_file" | cut -d'|' -f2 | sed 's/lua\/plugins\//  - /' | sort | uniq
done

echo
echo "=== CHECKING WHICH-KEY COVERAGE ==="

# Extract Leader keybindings from main astrocore.lua
echo "Leader keybindings in astrocore.lua:"
grep -o '\["<Leader>[^"]*>"\]' lua/plugins/astrocore.lua | sed 's/\["//;s/"\]//' | sort | uniq > /tmp/leader_keys.txt

# Check if they exist in which-key.lua
echo
echo "Checking which-key coverage..."
while read key; do
    # Extract the part after <Leader>
    key_part=$(echo "$key" | sed 's/<Leader>//')
    
    # Search in which-key.lua (accounting for different possible formats)
    if ! grep -q "$key_part" lua/plugins/which-key.lua 2>/dev/null; then
        echo "  Missing in which-key: $key"
    fi
done < /tmp/leader_keys.txt

echo
echo "=== SUMMARY OF ISSUES ==="

# Count astrocore files
astrocore_count=$(ls lua/plugins/astrocore*.lua 2>/dev/null | grep -v '.bak' | wc -l)
echo "- Number of astrocore configuration files: $astrocore_count"

if [ "$astrocore_count" -gt 1 ]; then
    echo "  WARNING: Multiple astrocore files detected! This will cause conflicts."
    echo "  Recommended: Keep only astrocore.lua and remove the others."
fi

# Count total unique keybindings
total_bindings=$(cat "$temp_file" | cut -d'|' -f1 | sort | uniq | wc -l)
echo "- Total unique keybindings found: $total_bindings"

# Count duplicates
dup_count=$(cat "$temp_file" | cut -d'|' -f1 | sort | uniq -d | wc -l)
echo "- Keybindings defined in multiple files: $dup_count"

# Cleanup
rm -f "$temp_file" /tmp/leader_keys.txt