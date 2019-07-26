//load bpipe stages required for this pipeline
load 'ikzf1deletions_stages.groovy'



//path to custom Salmon index 
SALMONIDX = "/group/bioi1/andrewl/cancer_projects/all-gene-expression-and-ikzf1-deletion-finder/data/archive_beds_fasta/extended_transcriptome_replacedel47_del28_del48_del27_remove_redundant_pax5_bed_internal_combos_short.idx/"
NTHREADS = 4 // no. threads to use for mapping, then counting


// filter options
DEL47=0.05

//paired-end rna-seq pipeline, starting with data from SRA
run {
//    "%_R*.fastq.gz" * [ salmon_custom_quant  + collate_tpm]  +   filter_tpm +  filter_thresholds 
    "%_R*.fastq.gz" * [ salmon_custom_quant]  + filter_thresholds
}

