process MERGE_FASTQ_GZ {

    tag "${barcode}"
    publishDir path: "${params.outdir}/merged_fq", mode: 'copy'
    input:
    tuple val(barcode), path(fqs)

    output:
    tuple val(barcode), path("${barcode}.merged.fastq.gz"), emit: fq1
    path("${barcode}.merged.fastq.gz"), emit: fq2

    script:
    """
    zcat ${fqs.join(' ')} | gzip > ${barcode}.merged.fastq.gz
    """
}

