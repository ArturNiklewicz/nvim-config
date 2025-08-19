# Terminal Commands for Keybinding Extraction

## Quick One-Liners

### 1. Find ALL keybindings with locations:
```bash
# Comprehensive search for all keybinding patterns
rg -n --no-heading '(\["<[^>]+>"\]|vim\.keymap\.set|keys\s*=|keymap\()' --glob '*.lua' | sort
```

### 2. Extract Leader keybindings only:
```bash
rg -n '<Leader>[^"]*' --glob '*.lua' -o | sort -u
```

### 3. Find duplicate keybindings:
```bash
# Extract all keys and count occurrences
rg -o '\["(<[^>]+>)"\]|vim\.keymap\.set\([^,]+,\s*"([^"]+)"' --glob '*.lua' | \
  grep -oE '<[^>]+>|".+"' | sort | uniq -c | sort -rn | grep -v '^ *1 '
```

### 4. Extract by mode (normal mode example):
```bash
# Normal mode keybindings
rg -B1 -A1 'n\s*=\s*\{|vim\.keymap\.set\("n"' --glob '*.lua'
```

### 5. Find keybindings in specific file:
```bash
# Single file analysis
rg -n '(\["[^"]+"\]\s*=|vim\.keymap\.set|keys\s*=)' lua/plugins/astrocore.lua
```

## Parametrized Loop Workflow

### Complete extraction loop:
```bash
#!/bin/bash

# Define patterns to search
patterns=(
  '\["<[^>]+>"\]\s*='                    # ["<Leader>x"] = 
  'vim\.keymap\.set\([^)]+\)'            # vim.keymap.set(...)
  'keys\s*=\s*\{[^}]+\}'                 # keys = { ... }
  'keymap\([^)]+\)'                      # keymap(...)
  '\["[\[\]][^"]*"\]\s*='                # ["]x"] = navigation
)

# Define file patterns
file_patterns=(
  "lua/plugins/*.lua"
  "lua/*.lua"
  "init.lua"
)

# Loop through each pattern and file
for pattern in "${patterns[@]}"; do
  echo "=== Searching for pattern: $pattern ==="
  for file_pattern in "${file_patterns[@]}"; do
    echo "  In files: $file_pattern"
    rg -n "$pattern" --glob "$file_pattern" 2>/dev/null | while IFS=: read -r file line match; do
      echo "    $file:$line - $match"
    done
  done
  echo ""
done
```

## Advanced Extraction with Context

### Extract with full context:
```bash
# Get keybinding with description
rg -U -A2 -B2 '\["<[^>]+>"\]\s*=\s*\{[^}]*desc[^}]*\}' --glob '*.lua' | \
  awk '/\[/{key=$0} /desc/{desc=$0; print FILENAME":"NR" "key" -> "desc}'
```

### Extract and format as CSV:
```bash
# CSV output: file,line,mode,key,description
rg -n --no-heading 'vim\.keymap\.set\("([^"]+)",\s*"([^"]+)"' --glob '*.lua' | \
  sed -E 's/([^:]+):([0-9]+):.*"([^"]+)",\s*"([^"]+)".*/\1,\2,\3,\4,keybinding/'
```

## Complete Workflow Script Usage

### Basic usage:
```bash
# Extract all keybindings
./extract-all-keybindings.sh

# Advanced analyzer with parameters
./keybinding-analyzer.sh . all        # All formats
./keybinding-analyzer.sh . csv        # CSV only
./keybinding-analyzer.sh . json       # JSON only
./keybinding-analyzer.sh . summary    # Summary only

# Filter by mode
./keybinding-analyzer.sh . all normal # Normal mode only
./keybinding-analyzer.sh . csv visual # Visual mode only
```

## Validation Commands

### Check for conflicts:
```bash
# Find same key mapped multiple times
cat keybindings_*.csv | awk -F',' 'NR>1 {print $3":"$4}' | \
  sort | uniq -c | sort -rn | awk '$1>1 {print}'
```

### Find unmapped leader combinations:
```bash
# Generate all possible leader+letter combinations and check which are unused
for letter in {a..z}; do
  if ! rg -q "<Leader>$letter" --glob '*.lua'; then
    echo "<Leader>$letter is available"
  fi
done
```

### Analyze keybinding distribution:
```bash
# Show which leader prefixes are most used
rg -o '<Leader>.' --glob '*.lua' | sort | uniq -c | sort -rn
```

## Integration with Neovim

### Run from within Neovim:
```vim
" List all keybindings
:!./extract-all-keybindings.sh

" Check for duplicates
:!rg -o '<Leader>[^"]*' --glob '*.lua' | sort | uniq -c | sort -rn | grep -v '^ *1 '

" Open results in new buffer
:enew | r !./keybinding-analyzer.sh . summary
```

## Performance Tips

1. **Use ripgrep (rg)** instead of grep - it's much faster
2. **Limit file scope** with --glob patterns
3. **Use parallel processing** for large codebases:
   ```bash
   find . -name "*.lua" | parallel -j4 'rg -n "keybinding_pattern" {}'
   ```
4. **Cache results** for repeated analysis:
   ```bash
   ./keybinding-analyzer.sh . all
   # Results are timestamped for comparison
   ```