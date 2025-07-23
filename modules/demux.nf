process DEMULTIPLEX {
 
    publishDir path: "${params.outdir}/demuxed_reads", mode: 'copy'
    
    input:
    path(fq)
    path(barcodes)

    output:
    path("demux_*.fastq.gz")

    script:
    """
    cutadapt -e 0.1 --no-indels \\
      -g file:${barcodes} \\
      -o demux_{name}.fastq.gz \\
      ${fq}
    """
}
