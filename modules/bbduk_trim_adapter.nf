process BBDukTrimAdapters {
    tag "${pair_id}"
    publishDir path: "${params.outdir}/bbduk_trim", mode: 'copy'
    input:
    tuple val(pair_id), path(fq)
    each path(adapters)

    output:
    tuple val(pair_id), path("${pair_id}_trimmed.fastq.gz")

    script:
    """
    bbduk.sh \
        in=${fq} \
        out=${pair_id}_trimmed.fastq.gz \
        ref=${adapters} \
        ktrim=r \
        k=23 \
        mink=14 \
        hdist=0 \
        tpe \
        tbo
    """
}

