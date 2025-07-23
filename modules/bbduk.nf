process BBDUK_ADAPTER_REMOVAL {
    tag "$pair_id"
    
    publishDir "${params.outdir}/trimmed", mode: 'copy'
    
    input:
    tuple val(pair_id), path(fq)
    each  path(adapters)
    
    output:
    tuple val(pair_id), path("*trimmed*R1_001.fastq.gz"), emit: trimmed_reads
    path("${pair_id}_bbduk.log"), emit: log
    
    script:
    """
    bbduk.sh \\
        in=${fq} \\
        out=${pair_id}_trimmed_R1_001.fastq.gz \\
        ref=${adapters} \\
        hdist=1 \\
        ktrim=l \\
        k=19 \
        mink=11 \
        hdist=1 \
        threads=${task.cpus} \\
        -Xmx${task.memory.toGiga()}g \\
        2> ${pair_id}_bbduk.log
    """
    
    stub:
    """
    touch ${pair_id}_trimmed_R1_001.fastq.gz
    touch ${pair_id}_bbduk.log
    """
}
