#!/bin/bash
set -euo pipefail

# Arguments
pool_id=$1
error_rate=$2
summary_file="${pool_id}_${error_rate}_barcode_report.csv"

# Initialize
declare -A barcode_counts
total_reads=0
unknown_reads=0
other_barcodes_reads=0

# Process each barcode file
for file in *.fastq.gz; do
    # Get barcode name (remove .fastq.gz extension)
    barcode="${file%.fastq.gz}"
    
    # Safely count reads (returns 0 if empty or error)
    reads=$((zcat "$file" 2>/dev/null | awk 'END{print NR/4}' 2>/dev/null) || echo 0)
    
    # Categorize as known or unknown barcode
    if [[ "$barcode" == "unknown" || "$barcode" == "unknown.merged" || "$barcode" == "unknown.trimmed.R1_001" ]]; then
        unknown_reads=$((unknown_reads + reads))
    else
        barcode_counts["$barcode"]=$reads
        total_reads=$((total_reads + reads))
    fi
done

# Add unknown reads to total
total_reads=$((total_reads + unknown_reads))

# Calculate other barcodes (count < 100)
declare -A final_barcode_counts
for barcode in "${!barcode_counts[@]}"; do
    count=${barcode_counts[$barcode]}
    if [[ $count -lt 100 ]]; then
        other_barcodes_reads=$((other_barcodes_reads + count))
    else
        final_barcode_counts["$barcode"]=$count
    fi
done

# Calculate percentages
unknown_pct=$(awk -v u=$unknown_reads -v t=$total_reads 'BEGIN{printf "%.2f", (t>0)?u*100/t:0}')
other_barcodes_pct=$(awk -v o=$other_barcodes_reads -v t=$total_reads 'BEGIN{printf "%.2f", (t>0)?o*100/t:0}')
demux_rate=$(awk -v u=$unknown_pct -v o=$other_barcodes_pct 'BEGIN{printf "%.2f", 100 - u - o}')

# Generate report
{
    # Header with summary stats
    echo "Total Reads:,${total_reads}"
    echo "Unknown Reads:,${unknown_reads},${unknown_pct}%"
    echo "Other Barcodes (count < 100):,${other_barcodes_reads},${other_barcodes_pct}%"
    echo "Demux Rate:,${demux_rate}%"
    echo ""
    echo "Barcode,Read_Count,Percent_of_Total"
    
    # Known barcodes (sorted)
    for barcode in $(printf '%s\n' "${!final_barcode_counts[@]}" | sort -V); do
        count=${final_barcode_counts[$barcode]}
        echo "${barcode},${count},$(awk -v c=$count -v t=$total_reads 'BEGIN{printf "%.2f", (t>0)?c*100/t:0}')"
    done
    
    # Other barcodes entry
    [[ $other_barcodes_reads -gt 0 ]] && \
        echo "other_barcodes,${other_barcodes_reads},${other_barcodes_pct}"
    
    # Unknown barcode (if exists)
    [[ $unknown_reads -gt 0 ]] && \
        echo "unknown.merged,${unknown_reads},${unknown_pct}"
} > "$summary_file"

echo "Successfully generated: $summary_file"
