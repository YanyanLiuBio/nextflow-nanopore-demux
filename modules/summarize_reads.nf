process SUMMARIZE_READS {
    tag "$pool_id"

    input:
    tuple val(pool_id), path(fq)

    output:
    path("${pool_id}.read_summary.txt")

    script:
    """
    summarise_reads.sh "${params.pool_ID}"
    """
}

