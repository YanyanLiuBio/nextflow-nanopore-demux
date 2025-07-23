#!/usr/bin/env bash

set -euo pipefail

pool_id="$1"
out_file="${pool_id}.read_summary.txt"

tmp_lengths="$(mktemp)"
sorted_lengths="$(mktemp)"

# Find fastq.gz files in current directory
shopt -s nullglob
fqs=(*.fastq.gz)
if [[ ${#fqs[@]} -eq 0 ]]; then
    echo "❌ No *.fastq.gz files found in $(pwd)" >&2
    exit 1
fi

# Collect read lengths
for f in "${fqs[@]}"; do
    echo "📂 Processing $f..." >&2
    zcat "$f" | awk '(NR%4==2){print length($0)}' >> "$tmp_lengths"
done

sort -n "$tmp_lengths" > "$sorted_lengths"

count=$(wc -l < "$sorted_lengths")
mean=$(awk '{sum+=$1} END{if(NR>0){print sum/NR}}' "$sorted_lengths")
min=$(head -n 1 "$sorted_lengths")
max=$(tail -n 1 "$sorted_lengths")

mid=$((count / 2))
if (( count % 2 == 1 )); then
    median=$(awk "NR==$((mid+1))" "$sorted_lengths")
else
    val1=$(awk "NR==$mid" "$sorted_lengths")
    val2=$(awk "NR==$((mid+1))" "$sorted_lengths")
    median=$(echo "scale=2; ($val1 + $val2)/2" | bc)
fi

q10_index=$((count * 10 / 100))
q25_index=$((count * 25 / 100))
q75_index=$((count * 75 / 100))

q10=$(awk "NR==$q10_index" "$sorted_lengths")
q25=$(awk "NR==$q25_index" "$sorted_lengths")
q75=$(awk "NR==$q75_index" "$sorted_lengths")

# Output TSV
{
    echo -e "pool_id\ttotal_reads\tmean\tmedian\tmin\tmax\tq10\tq25\tq75"
    echo -e "${pool_id}\t${count}\t${mean}\t${median}\t${min}\t${max}\t${q10}\t${q25}\t${q75}"
} > "$out_file"

rm "$tmp_lengths" "$sorted_lengths"
