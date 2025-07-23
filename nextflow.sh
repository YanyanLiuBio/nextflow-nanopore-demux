#!/bin/bash

outdir=1_error_500bp_20250722
error_rate=0.06
pool_ID=20250722
length_filter=500

/software/nextflow-align/nextflow run \
main.nf \
--error_rate $error_rate \
--outdir $outdir \
--length_filter $length_filter \
--pool_ID $pool_ID \
-resume -bg
