#!/bin/bash

# ==== CONFIG ====
search_dir="."                       # Start from the current directory (recursively)
combined_output="/c/Users/agrey25/Desktop/august_data_combined.csv"

# ==== SETUP ====
echo "[START] Searching all directories for August chunk files"
temp_header_written=false

# ==== FIND AND COMBINE ====
find "$search_dir" -type f -name "aug_chunk_*.csv.gz" | while read file; do
    echo "[INFO] Found: $file"

    if [ "$temp_header_written" = false ]; then
        # Write header from the first file
        zcat "$file" | head -n 1 > "$combined_output"
        temp_header_written=true
    fi

    # Append data excluding the header (skip first line after unzipping)
    zcat "$file" | tail -n +2 >> "$combined_output"
done

echo "[DONE] All August chunk files combined into: $combined_output"

