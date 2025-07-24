

include { CUTADAPT_DEMUX_SE   }  from './modules/demux_cutadapt_one_end.nf'
include { CUTADAPT_TRIM   }  from './modules/cutadapt_trim.nf'
include { MERGE_FASTQ_GZ } from './modules/merge_fastq_gz.nf'
include { SUMMARIZE_READS as SUMMARIZE_READS_ONT_FQ } from './modules/summarize_reads.nf'
include { SUMMARIZE_READS as SUMMARIZE_READS_DEMUX_FILTERED_FQ } from './modules/summarize_reads.nf'
include { SUMMARIZE_READS as SUMMARIZE_READS_DEMUX_TRIMMED_FQ } from './modules/summarize_reads.nf'
include { COMBINE_READ_STATS } from './modules/combine_read_stats.nf'
include { SUMMARIZE_MERGED_BARCODES_DEMUX } from './modules/summarize_merged_barcodes_demux.nf'
include { SUMMARIZE_MERGED_BARCODES_TRIM } from './modules/summarize_merged_barcodes_trim.nf'

workflow {

    
    Channel
        .fromPath( params.input_path + "/*.fastq.gz")
        .map{ it-> tuple(it.baseName.replace(".fastq",""), it)} 
        .set { fq_ch }

    Channel
        .fromPath("fastq/*.fastq.gz")
        .map {it -> tuple( params.pool_ID, it)}
        .set { fq_ch2 }
    SUMMARIZE_READS_ONT_FQ( fq_ch2) 
    Channel
        .fromPath('barcodes.fa')
        .set { barcode_ch }



    demux_out = CUTADAPT_DEMUX_SE(fq_ch, barcode_ch)



    demux_out.flatten()
    .map { file ->
    def name = file.getName()
    
     def barcode = name.find(/BC_\d+/) ?: 
                      (name.contains('unknown') ? 'unknown' : 
                      { 
                          log.warn "No valid barcode found in filename: ${name}"
                          'unclassified'
                      }())
    
      tuple(barcode, file)
    }
    .groupTuple()
    .set { grouped_reads_ch } 


   merged_reads_ch = MERGE_FASTQ_GZ (grouped_reads_ch)
   merged_reads_ch_2 = merged_reads_ch.fq2.collect()
                     .map { it -> tuple( params.pool_ID, it)}

  
  SUMMARIZE_READS_DEMUX_FILTERED_FQ (merged_reads_ch_2)
  SUMMARIZE_MERGED_BARCODES_DEMUX (merged_reads_ch_2)

   trim_ch = CUTADAPT_TRIM( merged_reads_ch.fq1 )
   trim_ch_2 = trim_ch.fq2.collect()
               .map { it-> tuple( params.pool_ID, it) }
               
   SUMMARIZE_READS_DEMUX_TRIMMED_FQ( trim_ch_2)
   reports_ch = SUMMARIZE_READS_ONT_FQ.out.mix(SUMMARIZE_READS_DEMUX_FILTERED_FQ.out).mix(SUMMARIZE_READS_DEMUX_TRIMMED_FQ.out).collect()
               .map{ it -> tuple(params.pool_ID, it) }
 
   SUMMARIZE_MERGED_BARCODES_TRIM(trim_ch_2) 

   COMBINE_READ_STATS(reports_ch)    
}
