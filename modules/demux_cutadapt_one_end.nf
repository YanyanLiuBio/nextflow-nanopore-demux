process CUTADAPT_DEMUX_SE {
    tag "$pair_id"
    publishDir path: "${params.outdir}/demuxed_reads_single_end", mode: 'copy'

    input:
    tuple val(pair_id), path(fq1)
    each path(barcodes)

    output:
    path("*_001.fastq.gz")

    script:
    """
    cutadapt  --no-indels \\
       --minimum-length ${params.length_filter} \\
        -g file:${barcodes} \\
        -O 17 \\
        -e ${params.error_rate} \\
        -o ${pair_id}_{name}_R1_001.fastq.gz \\
        ${fq1}
    """
}

