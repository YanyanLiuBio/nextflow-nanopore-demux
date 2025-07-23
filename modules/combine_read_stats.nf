process COMBINE_READ_STATS {
    tag "combine_reports"
    label 'process_single'
    
    publishDir "${params.outdir}/reports", mode: 'copy'
    
    input:
    tuple val(date_prefix),path(summary_files, stageAs: "input_?.txt")
    
    
    output:
    path("${date_prefix}.combined_read_summary.txt"), emit: combined_report
    path("versions.yml"), emit: versions
    
    when:
    task.ext.when == null || task.ext.when
    
    script:
    def args = task.ext.args ?: ''
    """
    #!/bin/bash
    
    # Initialize combined report with header from first file
    first_file=\$(ls input_*.txt | head -n1)
    
    # Create header with file_name column and remove first column only
    head -n1 "\$first_file" > temp_header.txt
    original_header=\$(cat temp_header.txt)
    remaining_header=\$(echo "\$original_header" | cut -f2-)
    echo -e "file_name\\t\$remaining_header" > ${date_prefix}.combined_read_summary.txt
    
    # Process each file and assign file type names
    file_types=("ONT_fq" "DEMUXED_fq" "TRIMMED_fq")
    file_index=0
    
    for file in input_*.txt; do
        # Skip header and process data
        if [ \$(wc -l < "\$file") -gt 1 ]; then
            tail -n +2 "\$file" > temp_data.txt
            
            # Add row with corresponding file type name
            data_line=\$(cat temp_data.txt)
            if [ -n "\$data_line" ] && [ \$file_index -lt 3 ]; then
                # Remove first column only and add file type name
                remaining_data=\$(echo "\$data_line" | cut -f2-)
                current_type=\$(echo "ONT_fq DEMUXED_fq TRIMMED_fq" | cut -d' ' -f\$((file_index + 1)))
                echo -e "\$current_type\\t\$remaining_data" >> ${date_prefix}.combined_read_summary.txt
                file_index=\$((file_index + 1))
            fi
        fi
    done
    
    # Clean up temp files
    rm -f temp_header.txt temp_data.txt
    
    # Create versions file
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bash: \$(bash --version | head -n1 | cut -d' ' -f4)
    END_VERSIONS
    """
    
    stub:
    """
    touch ${date_prefix}.combined_read_summary.txt
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bash: \$(bash --version | head -n1 | cut -d' ' -f4)
    END_VERSIONS
    """
}
