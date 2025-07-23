process FASTP {
    tag "$sample_id"
//    publishDir "${params.outdir}/fastp", mode: 'copy'

    input:
    tuple val(sample_id), path(fq1), path(fq2)

    output:
    tuple val(sample_id), path("${sample_id}_R1.fastp.fq.gz"), path("${sample_id}_R2.fastp.fq.gz")

    script:
    """
    fastp \
      -i ${fq1} \
      -I ${fq2} \
      -o ${sample_id}_R1.fastp.fq.gz \
      -O ${sample_id}_R2.fastp.fq.gz \
      --detect_adapter_for_pe \
      --thread 2
    """
}


