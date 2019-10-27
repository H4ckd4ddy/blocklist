#!/bin/bash

INPUT="blocklist.csv"
OUTPUT="outputs/blocklist.conf"

# Copy source to destination
cp $INPUT $OUTPUT

# Remove first line (csv header)
sed -i '1d' $OUTPUT

# Remove whitelisted lines
sed -i '/;WHITELISTED;/d' $OUTPUT

# Replace first ';' by record value
sed -i 's/;/ A 0\.0\.0\.0\";/' $OUTPUT

# Remove all after first ';' (don't add all informations, too large)
sed -i 's/;.*//' $OUTPUT

# Add unbound key at begining of each line
sed -i 's/^/local-data: \"/' $OUTPUT

echo 'Unbound conf file generated'
