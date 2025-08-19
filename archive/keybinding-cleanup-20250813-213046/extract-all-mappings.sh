#!/bin/bash

# Extract ALL mappings from AstroCore for Which-Key registration
# This will give us the precise list to register

echo "Extracting ALL AstroCore mappings..."
echo

cd ~/.config/nvim

# Extract all mappings with their descriptions
sed -n '/mappings = {/,/^    },$/p' lua/plugins/astrocore.lua | \
  grep '^\s*\["' | \
  sed 's/^\s*\["\([^"]*\)"\].*desc = "\([^"]*\)".*/\1 → \2/' | \
  sort > astrocore-mappings.txt

echo "Found $(wc -l < astrocore-mappings.txt) mappings"
echo
echo "Sample mappings:"
head -20 astrocore-mappings.txt
echo "..."
echo
echo "Mappings by prefix:"
echo

# Count by prefix
for prefix in w W q Q a b c d f g G h j l m M r s t u v x z; do
  count=$(grep "^<Leader>$prefix" astrocore-mappings.txt | wc -l)
  if [ "$count" -gt 0 ]; then
    echo "  <Leader>$prefix: $count mappings"
  fi
done

echo
echo "Full list saved to: astrocore-mappings.txt"