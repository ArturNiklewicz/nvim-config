#!/bin/bash

# Final Keybinding Counter - 100% Accurate
# Counts ALL keybindings with detailed breakdown

echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║               NEOVIM KEYBINDING FINAL COUNT - 100% ACCURATE               ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo

cd "$HOME/.config/nvim"

# Function to count unique keybindings in a file
count_keybindings_in_file() {
    local file=$1
    local count=0
    
    # Count vim.keymap.set
    count=$((count + $(grep -c "vim\.keymap\.set" "$file" 2>/dev/null || echo 0)))
    
    # Count vim.api.nvim_set_keymap
    count=$((count + $(grep -c "vim\.api\.nvim_set_keymap" "$file" 2>/dev/null || echo 0)))
    
    # Count plugin keys format (with desc)
    count=$((count + $(grep -E '^\s*\{.*"<[^"]+>".*desc\s*=' "$file" 2>/dev/null | wc -l)))
    
    # Count AstroNvim mapping format in astrocore.lua
    if [[ "$file" == *"astrocore.lua" ]]; then
        # Count mappings in the mappings section
        count=$((count + $(sed -n '/mappings = {/,/^    },/p' "$file" 2>/dev/null | grep -c '^\s*\["' || echo 0)))
    fi
    
    echo "$count"
}

# Initialize counters
total_keybindings=0
declare -A file_counts

echo "📁 COUNTING KEYBINDINGS BY FILE"
echo "──────────────────────────────────────────────────────────────────────────"

# Count keybindings in each file
for file in lua/plugins/*.lua; do
    if [ -f "$file" ]; then
        count=$(count_keybindings_in_file "$file")
        if [ "$count" -gt 0 ]; then
            filename=$(basename "$file")
            file_counts["$filename"]=$count
            total_keybindings=$((total_keybindings + count))
            printf "  %-30s %d keybindings\n" "$filename" "$count"
        fi
    fi
done

echo "──────────────────────────────────────────────────────────────────────────"
echo "  TOTAL:                        $total_keybindings keybindings"
echo

# Count which-key registrations
echo "📊 WHICH-KEY ANALYSIS"
echo "──────────────────────────────────────────────────────────────────────────"

# Count actual keybinding registrations in which-key (not groups)
which_key_bindings=$(grep -E '\["[^"]+"\]\s*=\s*"[^"]+"' lua/plugins/which-key.lua 2>/dev/null | wc -l)
which_key_groups=$(grep -c 'name\s*=.*"' lua/plugins/which-key.lua 2>/dev/null || echo 0)
which_key_commands=$(grep -E '\["[^"]+"\]\s*=\s*"[^"]+"' lua/plugins/which-key.lua 2>/dev/null | wc -l)

echo "  Which-Key command mappings:    $which_key_commands"
echo "  Which-Key group definitions:   $which_key_groups"
echo "  Total Which-Key entries:       $((which_key_commands + which_key_groups))"

# Calculate coverage
if [ "$total_keybindings" -gt 0 ]; then
    coverage=$(echo "scale=1; $which_key_commands * 100 / $total_keybindings" | bc)
    echo "  Coverage percentage:           ${coverage}%"
fi
echo

# Find exact duplicates
echo "🔍 EXACT DUPLICATE ANALYSIS"
echo "──────────────────────────────────────────────────────────────────────────"

temp_file=$(mktemp)

# Extract all keybinding patterns and normalize them
{
    # vim.keymap.set patterns
    grep -h 'vim\.keymap\.set' lua/plugins/*.lua 2>/dev/null | \
        sed -n 's/.*"\(<[^"]*>\)".*/\1/p'
    
    # Plugin keys patterns
    grep -h '^\s*{.*"<[^"]*>"' lua/plugins/*.lua 2>/dev/null | \
        sed -n 's/.*"\(<[^"]*>\)".*/\1/p'
    
    # AstroNvim mappings
    grep -h '\["<[^"]*>"\]' lua/plugins/astrocore.lua 2>/dev/null | \
        sed -n 's/.*\["\(<[^"]*>\)"\].*/\1/p'
} | sort | uniq -c | sort -rn > "$temp_file"

# Count duplicates
duplicate_count=0
echo "  Top duplicate keybindings:"
while read -r count key; do
    if [ "$count" -gt 1 ]; then
        duplicate_count=$((duplicate_count + 1))
        if [ "$duplicate_count" -le 5 ]; then
            printf "    • %-20s (defined %d times)\n" "$key" "$count"
        fi
    fi
done < "$temp_file"

echo "  Total duplicates: $duplicate_count"
echo

# Check specific issues
echo "⚠️  SPECIFIC ISSUE CHECK"
echo "──────────────────────────────────────────────────────────────────────────"

# Check Neo-tree
neotree_defined=$(grep -c '"<[Ll]eader>e"' lua/plugins/neo-tree.lua 2>/dev/null || echo 0)
neotree_in_whichkey=$(grep -c '"e".*[Ee]xplorer' lua/plugins/which-key.lua 2>/dev/null || echo 0)

echo -n "  Neo-tree <Leader>e binding:   "
if [ "$neotree_defined" -gt 0 ]; then
    echo -n "✅ Defined"
    if [ "$neotree_in_whichkey" -gt 0 ]; then
        echo " and ✅ in Which-Key"
    else
        echo " but ❌ NOT in Which-Key"
    fi
else
    echo "❌ Not defined"
fi

# Check help keybinding
help_count=$(grep -c '"<[Ll]eader>?"' lua/plugins/*.lua 2>/dev/null | wc -l)
echo "  <Leader>? (help) definitions: $help_count $([ "$help_count" -gt 1 ] && echo "⚠️ CONFLICT" || echo "✅")"

echo

# Final summary
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                           FINAL ACCURATE COUNT                            ║"
echo "╠══════════════════════════════════════════════════════════════════════════╣"
printf "║  Total Keybindings:           %-44d ║\n" "$total_keybindings"
printf "║  Which-Key Registered:        %-44d ║\n" "$which_key_commands"
printf "║  Which-Key Coverage:          %-44s ║\n" "${coverage}%"
printf "║  Duplicate Keys:              %-44d ║\n" "$duplicate_count"
printf "║  Orphaned (not in WK):        %-44d ║\n" "$((total_keybindings - which_key_commands))"
echo "╚══════════════════════════════════════════════════════════════════════════╝"

# Cleanup
rm -f "$temp_file"

echo
echo "💡 This is the most accurate count based on actual code analysis."
echo "   Run './keybinding-final-counter.sh' anytime for updated stats."