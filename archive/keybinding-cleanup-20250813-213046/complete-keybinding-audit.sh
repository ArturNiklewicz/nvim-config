#!/bin/bash

echo "=== COMPLETE KEYBINDING AUDIT FOR NVIM CONFIG ==="
echo "Generated on: $(date)"
echo

output_file="COMPLETE_KEYBINDING_AUDIT.md"

cat > "$output_file" << 'EOF'
# Complete Keybinding Audit

Generated on: DATE_PLACEHOLDER

## All Keybindings by File

EOF

sed -i '' "s/DATE_PLACEHOLDER/$(date)/" "$output_file"

# Function to extract keybindings from a file
extract_keybindings() {
    local file=$1
    local temp_bindings="/tmp/bindings_$$.txt"
    
    # Extract mappings table entries
    grep -n '\["[^"]*"\]\s*=' "$file" 2>/dev/null | while read -r line; do
        line_num=$(echo "$line" | cut -d: -f1)
        full_line=$(echo "$line" | cut -d: -f2-)
        key=$(echo "$full_line" | grep -o '\["[^"]*"\]' | sed 's/\["//;s/"\]//')
        if [[ "$key" == *"<"* ]]; then  # Only process if it looks like a keybinding
            # Extract description if available
            desc=$(echo "$full_line" | grep -o 'desc\s*=\s*"[^"]*"' | sed 's/desc\s*=\s*"//;s/"$//')
            [ -z "$desc" ] && desc="No description"
            echo "| \`$key\` | $desc | Line $line_num |" >> "$temp_bindings"
        fi
    done
    
    # Extract vim.keymap.set calls
    grep -n 'vim\.keymap\.set' "$file" 2>/dev/null | while read -r line; do
        line_num=$(echo "$line" | cut -d: -f1)
        full_line=$(echo "$line" | cut -d: -f2-)
        # Extract mode and key
        mode=$(echo "$full_line" | sed -n 's/.*vim\.keymap\.set(\s*["'\'']\([^"'\'']*\)["'\''].*/\1/p')
        key=$(echo "$full_line" | sed -n 's/.*vim\.keymap\.set([^,]*,\s*["'\'']\([^"'\'']*\)["'\''].*/\1/p')
        if [ -n "$mode" ] && [ -n "$key" ]; then
            # Extract description
            desc=$(echo "$full_line" | grep -o 'desc\s*=\s*"[^"]*"' | sed 's/desc\s*=\s*"//;s/"$//')
            [ -z "$desc" ] && desc="No description"
            echo "| \`$key\` | [$mode] $desc | Line $line_num |" >> "$temp_bindings"
        fi
    done
    
    # Sort and output if any bindings found
    if [ -f "$temp_bindings" ] && [ -s "$temp_bindings" ]; then
        echo -e "\n### $file\n" >> "$output_file"
        echo "| Key | Description | Location |" >> "$output_file"
        echo "|-----|-------------|----------|" >> "$output_file"
        sort -u "$temp_bindings" >> "$output_file"
    fi
    
    rm -f "$temp_bindings"
}

# Process all lua files
find ./lua/plugins -name "*.lua" -type f | sort | while read file; do
    extract_keybindings "$file"
done

# Add summary section
echo -e "\n## Duplicate Analysis\n" >> "$output_file"

# Find duplicates across all files
temp_all="/tmp/all_bindings_$$.txt"
find ./lua/plugins -name "*.lua" -type f | while read file; do
    grep '\["<[^"]*>"\]\s*=' "$file" 2>/dev/null | while read -r line; do
        key=$(echo "$line" | grep -o '\["[^"]*"\]' | sed 's/\["//;s/"\]//')
        echo "$key|$file" >> "$temp_all"
    done
    grep 'vim\.keymap\.set' "$file" 2>/dev/null | while read -r line; do
        key=$(echo "$line" | sed -n 's/.*vim\.keymap\.set([^,]*,\s*["'\'']\([^"'\'']*\)["'\''].*/\1/p')
        [ -n "$key" ] && echo "$key|$file" >> "$temp_all"
    done
done

if [ -f "$temp_all" ]; then
    echo "### Keys Defined Multiple Times" >> "$output_file"
    echo >> "$output_file"
    
    cut -d'|' -f1 "$temp_all" | sort | uniq -c | sort -rn | grep -v '^ *1 ' | while read count key; do
        echo "- **\`$key\`** - Defined $count times in:" >> "$output_file"
        grep "^$key|" "$temp_all" | cut -d'|' -f2 | sort -u | sed 's/^/  - /' >> "$output_file"
        echo >> "$output_file"
    done
fi

rm -f "$temp_all"

echo
echo "Audit complete! Results saved to: $output_file"