# Utility of RNA sequencing for the diagnosis and genomic classification of paediatric acute lymphoblastic leukaemia

Additional data and scripts for the paper.

# Gene expression

Gene expression tables for the underlying 126 ALL RNA-seq samples are available in the `counts` directory:

- counts_raw.txt  - gene counts


# IKZF1 Deletion Detection

Script to perform the IKZF1 deletion detection are described below:

## Requirements

- bedtools
- salmon  > v0.12

Additional data:

- reference genome 
- reference transcriptome

## Define deletions

For the gene of interest, IKZF1, we define a BED12 format `.bed` file with the exons to be retained for each of del2-8, del2-7, del4-7 and del4-8, and a modified sequence name to indicate the unique transcript modification (col 4) in a `deletions.bed` file:

```
chr7	50304715	50405101	ENST00000331340_del27	0	+	50319061	50400627	0	2	207,5184,	0,95202,
chr7	50304715	50405101	ENST00000331340_del28	0	+	50319061	50400627	0	2	207,1,	0,208,
chr7	50304715	50405101	ENST00000331340_del47	0	+	50319061	50400627	0	4	207,54,120,5184,	0,14332,22922,95202,
chr7	50304715	50405101	ENST00000331340_del48	0	+	50319061	50400627	0	3	207,54,120,	0,14332,22922,

```

Next, create the transcripts with `bedtools`:

```bash
bedtools getfasta -fi reference_genome.fasta  -bed deletions.bed  -split  -name > deletions.fasta
```

Note: due to limitations with the `getfasta` a description of one exon fail to produce a truncated sequence. One workaround is to define a second small exon and then manually delete it from the resulting FASTA, as we have done for del28.

Example `.bed` and `.fasta` files are provided in the `bed` and `fasta` directories respectivley for IKZF1. 

These deletion transcripts are then appended to the reference transcriptome:

```bash
cat reference_transcriptome.fasta deletion.fasta > extended_transcriptome.fasta
```

Note: if there are specific existing transcripts that contain the missing exons, as was the case for del4-7 and ENST00000426121.1, then the reference transcriptome should be modified to remove them first.


Once created, the extended transcriptome can be indexed in the usual way. Using Salmon:

```bash
salmon index -t  extended_transcriptome.fasta -i  extended_transcriptome.idx/ -k 31
```

## Run Salmon

Samples can then be quantified  using this extended custom transcriptome, for example with paired end reads:

```bash
salmon quant  --dumpEq -i extended_transcriptome.idx/  -l A -1 r1.fastq.gz  -2 r2.fastq.gz  -o output_directory
```

## Extract deletion abundances

The primary output file from Salmon, `quant.sf` can now be analysed to extract the deletion abundances. Since all the deletion transcripts are named as an extension of a canonical IKZF1 transcript, then simply selecting all IKZF1 transcripts will capture the extended transcripts as well:

Using a file such as `ikzf1_transcripts.txt` with each transcript name:
```
ENST00000331340
ENST00000343574
ENST00000346667
ENST00000349824
ENST00000357364
ENST00000359197
ENST00000413698
ENST00000426121
ENST00000438033
ENST00000439701
ENST00000440768
ENST00000462201
ENST00000471793
ENST00000484847
ENST00000492119
ENST00000492782
ENST00000612658
ENST00000615491
ENST00000641948
ENST00000642219
ENST00000645066
ENST00000646110
```

can then be used to get the quantifications for the gene of interest:

```bash
grep -f ikzf1_transcripts.txt output/quant.sf > ikzf1.quant.sf
```

These results can then be analysed for the relative rank of the deletion transcripts, e.g. the fourth column of TPM:

```bash
cat ikzf1.quant.sf | sort -nrk4
```

## Calculate relative deletion percentage

Empirically, when the del4-7 transcript contributes 5% or more of the total TPM for IKZF1 a biochemcial assay via qPCR confirmed the deletion.

An R script, `filter_del47.R` takes two arguments (the threshold, and a complete `quant.sf`) and will calculate if a sample exceeds this threshold.

```bash
 R --vanilla --args --del47 0.05  --files ikzf1.quant.sf < filter_del47.R
```

Multiple files can be seperated by `:`.

It will return two files: `ikzf1_tpms.csv` which contains the reference and extended TPM values for each sample, and `threshold_results.csv` which will indicate TRUE/FALSE for each sample if the del4-7 transcript exceeded the threshold.


## Bpipe scripts

A Bpipe (http://bpipe.org) pipeline for testing samples against a custom index is provided in `ikzf1deletions.groovy` and can be invoked:  

```bash
bpipe  -n NUM_THREADS  ikzf1deletions.groovy  <fastq_files>
```

which will quantify the samples against the custom index with Salmon and run `filer_del47.R`.


## Generalised methods for other genes

By defining a `.bed` file with the expected deletion transcripts and collating all original and modified transcripts of a gene, the approaches used here can be modified for any gene type.  

Extending the deletion methods described here to any gene of interest automatically is also in development as Toblerone (https://github.com/Oshlack/Toblerone/).
