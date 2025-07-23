process SUMMARIZE_MERGED_BARCODES_TRIM {
    tag "$pool_ID"
    publishDir "${params.outdir}/reports", mode: 'copy'
    input:
    tuple val(pool_ID), path(fq_files)

    output:
     path("*.csv")

    script:
    """
    summarize_merged_barcodes.sh "$pool_ID"_TRIM "${params.error_rate}"
    """
}

