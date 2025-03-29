import os
import gzip
import csv

# ==== CONFIG ====
search_dir = "."  # Start from current directory
combined_output = "all_parts_combined.csv"
header_written = False

# ==== COMBINE CSV FILES ====
with open(combined_output, "w", newline='', encoding='utf-8') as out_file:
    writer = None

    for root, dirs, files in os.walk(search_dir):
        for file in files:
            if file.endswith(".csv.gz"):
                file_path = os.path.join(root, file)
                print(f"[INFO] Found: {file_path}")

                with gzip.open(file_path, "rt", encoding='utf-8') as f:
                    reader = csv.reader(f)
                    try:
                        header = next(reader)
                    except StopIteration:
                        continue  # skip empty files

                    if not header_written:
                        writer = csv.writer(out_file)
                        writer.writerow(header)
                        header_written = True

                    writer.writerows(reader)

print(f"[DONE] All CSV files combined into: {combined_output}")

