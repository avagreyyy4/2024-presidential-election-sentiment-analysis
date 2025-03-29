#!/bin/bash

# ==== CONFIG ====
input_file="/c/Users/agrey25/Desktop/all_data_combined.csv"
output_file="/c/Users/agrey25/Desktop/filtered_data.csv"
start_date="2024-07-23"
end_date="2024-11-04"
date_col=30
log_interval=1000000  # Show progress every 1 million lines

# ==== SETUP ====
echo "[START] Filtering $input_file between $start_date and $end_date"
mkdir -p "$(dirname "$output_file")"
header=$(head -n 1 "$input_file")
echo "$header" > "$output_file"

# ==== STREAM + FILTER + PROGRESS ====
tail -n +2 "$input_file" | awk -F, -v sd="$start_date" -v ed="$end_date" -v col="$date_col" -v interval="$log_interval" '
BEGIN {
    OFS=FS
    line_num = 0
    matched = 0
}
{
    line_num++
    date = $col
    gsub(/"/, "", date)

    if (date >= sd && date <= ed) {
        print $0 >> "'"$output_file"'"
        matched++
    }

    if (line_num % interval == 0) {
        printf("[INFO] Processed %d lines, matched %d rows so far...\n", line_num, matched) > "/dev/stderr"
    }
}
END {
    printf("[DONE] Total lines processed: %d | Total matched: %d\n", line_num, matched) > "/dev/stderr"
}
'

