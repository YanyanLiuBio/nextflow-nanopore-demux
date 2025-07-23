process CUTADAPT_TRIM {
    tag "$pair_id"
    publishDir path: "${params.outdir}/cutadapt_trim", mode: 'copy'
    input:
    tuple val(pair_id), path(fq)

    output:
    tuple val(pair_id), path("${pair_id}.trimmed.R1_001.fastq.gz"), emit: fq1
    path("${pair_id}.trimmed.R1_001.fastq.gz"), emit:fq2
    script:
    """
    cutadapt \\
        -g AATGATACGGCGACCACCGAGATCTACAC \\
        -g AGATGTGTATAAGAGACAG \\
        --minimum-length 150 \
        --overlap 10 \
        -o ${pair_id}.trimmed.R1_001.fastq.gz \\
        ${fq} 
    """
}

