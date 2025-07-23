process BBREPAIR {

    tag "$sample_id"

    input:
    tuple  val(sample_id), path(fq1), path(fq2)

    output:
    tuple  val(sample_id), path("clean_${fq1.baseName}.gz"), path("clean_${fq2.baseName}.gz")

    script:
    """
    repair.sh \
        in1=${fq1} \
        in2=${fq2} \
        out1=clean_${fq1.baseName}.gz \
        out2=clean_${fq2.baseName}.gz \
        outs=singles.fq.gz
    """
}


