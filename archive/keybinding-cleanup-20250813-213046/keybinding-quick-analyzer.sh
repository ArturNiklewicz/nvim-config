#!/bin/bash

# Quick Keybinding Analyzer
# Fast and accurate keybinding analysis for Neovim configuration

echo "════════════════════════════════════════════════════════════════════════════"
echo "                    NEOVIM KEYBINDING QUICK ANALYSIS"
echo "════════════════════════════════════════════════════════════════════════════"
echo

cd "$HOME/.config/nvim"

# Count total keybindings
echo "📊 KEYBINDING STATISTICS"
echo "────────────────────────────────────────────────────────────────────────"

# Count vim.keymap.set
vim_keymap_count=$(grep -h "vim\.keymap\.set" lua/plugins/*.lua 2>/dev/null | wc -l)
echo "  vim.keymap.set calls:                 $vim_keymap_count"

# Count nvim_set_keymap
nvim_set_count=$(grep -h "vim\.api\.nvim_set_keymap" lua/plugins/*.lua 2>/dev/null | wc -l)
echo "  vim.api.nvim_set_keymap calls:        $nvim_set_count"

# Count plugin keys definitions
plugin_keys=$(grep -h '^\s*{.*".*",.*desc\s*=' lua/plugins/*.lua 2>/dev/null | wc -l)
echo "  Plugin key definitions:                $plugin_keys"

# Count AstroNvim mappings
astro_mappings=$(grep -h '\[".*"\]\s*=\s*{' lua/plugins/astrocore.lua 2>/dev/null | wc -l)
echo "  AstroNvim mappings:                    $astro_mappings"

# Count which-key registrations
which_key_bindings=$(grep -h '\[".*"\]\s*=' lua/plugins/which-key.lua 2>/dev/null | grep -v "name =" | wc -l)
which_key_groups=$(grep -h 'name\s*=' lua/plugins/which-key.lua 2>/dev/null | wc -l)
echo "  Which-key bindings:                    $which_key_bindings"
echo "  Which-key groups:                      $which_key_groups"

# Calculate totals
total_bindings=$((vim_keymap_count + nvim_set_count + plugin_keys + astro_mappings))
echo "────────────────────────────────────────────────────────────────────────"
echo "  TOTAL KEYBINDINGS:                    $total_bindings"
echo "  Which-key registered:                  $which_key_bindings"
echo "  Potential orphaned:                    $((total_bindings - which_key_bindings))"
echo

# Find duplicates
echo "🔍 DUPLICATE DETECTION"
echo "────────────────────────────────────────────────────────────────────────"

# Extract all keybindings and find duplicates
temp_file=$(mktemp)
temp_duplicates=$(mktemp)

# Extract keybindings from various sources
grep -h '"<[^"]*>"' lua/plugins/*.lua 2>/dev/null | \
  sed -n 's/.*"\(<[^"]*>\)".*/\1/p' | \
  sort | uniq -c | sort -rn | \
  awk '$1 > 1 {print $2 " (defined " $1 " times)"}' > "$temp_duplicates"

duplicate_count=$(wc -l < "$temp_duplicates")

if [ "$duplicate_count" -gt 0 ]; then
    echo "  Found $duplicate_count duplicate keybinding definitions:"
    head -10 "$temp_duplicates" | while read line; do
        echo "    • $line"
    done
    if [ "$duplicate_count" -gt 10 ]; then
        echo "    ... and $((duplicate_count - 10)) more"
    fi
else
    echo "  ✅ No duplicate keybindings found!"
fi
echo

# Mode distribution
echo "📈 MODE DISTRIBUTION"
echo "────────────────────────────────────────────────────────────────────────"

# Count by mode (approximate)
normal_count=$(grep -h '["'\'']n["'\'']' lua/plugins/*.lua 2>/dev/null | grep -E "vim\.(keymap\.set|api\.nvim_set_keymap)" | wc -l)
visual_count=$(grep -h '["'\'']v["'\'']' lua/plugins/*.lua 2>/dev/null | grep -E "vim\.(keymap\.set|api\.nvim_set_keymap)" | wc -l)
insert_count=$(grep -h '["'\'']i["'\'']' lua/plugins/*.lua 2>/dev/null | grep -E "vim\.(keymap\.set|api\.nvim_set_keymap)" | wc -l)
terminal_count=$(grep -h '["'\'']t["'\'']' lua/plugins/*.lua 2>/dev/null | grep -E "vim\.(keymap\.set|api\.nvim_set_keymap)" | wc -l)

echo "  Normal mode:    ~$normal_count"
echo "  Visual mode:    ~$visual_count"
echo "  Insert mode:    ~$insert_count"
echo "  Terminal mode:  ~$terminal_count"
echo

# File distribution
echo "📁 TOP FILES BY KEYBINDING COUNT"
echo "────────────────────────────────────────────────────────────────────────"

for file in lua/plugins/*.lua; do
    if [ -f "$file" ]; then
        count=$(grep -c -E "vim\.(keymap\.set|api\.nvim_set_keymap)|keys\s*=|\[.*\]\s*=\s*{" "$file" 2>/dev/null || echo 0)
        if [ "$count" -gt 0 ]; then
            echo "$count $(basename "$file")"
        fi
    fi
done | sort -rn | head -8 | while read count name; do
    printf "  %-30s %d\n" "$name" "$count"
done
echo

# Find potential conflicts
echo "⚠️  POTENTIAL CONFLICTS"
echo "────────────────────────────────────────────────────────────────────────"

# Look for common conflict patterns
conflicts=0

# Check for multiple <Leader>e definitions
leader_e_count=$(grep -h '"<[Ll]eader>e"' lua/plugins/*.lua 2>/dev/null | wc -l)
if [ "$leader_e_count" -gt 1 ]; then
    echo "  <Leader>e defined $leader_e_count times"
    conflicts=$((conflicts + 1))
fi

# Check for multiple <Leader>w definitions
leader_w_count=$(grep -h '"<[Ll]eader>w"' lua/plugins/*.lua 2>/dev/null | wc -l)
if [ "$leader_w_count" -gt 1 ]; then
    echo "  <Leader>w defined $leader_w_count times"
    conflicts=$((conflicts + 1))
fi

# Check for multiple <Leader>? definitions
leader_help_count=$(grep -h '"<[Ll]eader>?"' lua/plugins/*.lua 2>/dev/null | wc -l)
if [ "$leader_help_count" -gt 1 ]; then
    echo "  <Leader>? defined $leader_help_count times"
    conflicts=$((conflicts + 1))
fi

if [ "$conflicts" -eq 0 ]; then
    echo "  ✅ No obvious conflicts detected"
fi
echo

# Unbinded references
echo "🔗 POTENTIALLY UNBINDED REFERENCES"
echo "────────────────────────────────────────────────────────────────────────"

# Look for desc without keybinding
unbinded=$(grep -h 'desc\s*=\s*"[^"]*"' lua/plugins/*.lua 2>/dev/null | \
  grep -v "vim\.keymap\.set" | \
  grep -v "keys\s*=" | \
  wc -l)

echo "  Found $unbinded potential unbinded descriptions"
echo

# Summary
echo "════════════════════════════════════════════════════════════════════════════"
echo "                              EXECUTIVE SUMMARY"
echo "════════════════════════════════════════════════════════════════════════════"
echo
echo "  📊 Total Keybindings:           $total_bindings"
echo "  ✅ Which-Key Coverage:          $(awk "BEGIN {printf \"%.1f%%\", $which_key_bindings * 100.0 / $total_bindings}")"
echo "  ⚠️  Duplicates Found:            $duplicate_count"
echo "  🔍 Potential Conflicts:         $conflicts"
echo "  🔗 Unbinded References:         $unbinded"
echo
echo "════════════════════════════════════════════════════════════════════════════"

# Cleanup
rm -f "$temp_file" "$temp_duplicates" 2>/dev/null

echo
echo "💡 To see keybindings in action:"
echo "   • In Neovim: Press <Space> and wait to see which-key menu"
echo "   • In Neovim: Run :Keybindings or :Keys"
echo "   • In terminal: ./nvim-keys"
echo