# Filter samples and calculate del47 percentage

# called with two named arguments, files which is : seperated and del47, the threshold
args = R.utils::commandArgs(trailingOnly = TRUE, asValues = TRUE)
salmon_abundances  <- args$files
print(salmon_abundances)
# check for a :, invalid in filename but valid as seperator if more than one sample being passed in 
if(grepl(salmon_abundances,":",fixed=TRUE)){
salmon_abundances <- unlist(strsplit(salmon_abundances, split=":"))
} else {
salmon_abundances <- c(salmon_abundances)

}
print(salmon_abundances)
del47_threshold  <- args$del47


getTPM<-function(df){
   df$TPM
}

 
salmon_abundances_df <- lapply(salmon_abundances, read.csv, header=T , sep="\t")
salmon_abundances_df_tpm <- lapply(salmon_abundances_df, getTPM)

ens_names <- salmon_abundances_df[[1]]$Name
ens_names <- gsub("\\.del27","_del27",ens_names)
ens_names <- gsub("\\..*","",ens_names)

salmon_abundances_df_all <- do.call(cbind,salmon_abundances_df_tpm)
colnames(salmon_abundances_df_all) <- salmon_abundances 
rownames(salmon_abundances_df_all) <- ens_names

head(salmon_abundances_df_all)

ikzf1_transcripts <- read.table("ikzf1_transcripts_full.txt", header=FALSE, sep = "\n")

ikzf1_transcripts_full <- c("ENST00000331340_del27","ENST00000331340_del47","ENST00000331340_del48","ENST00000331340_del28",as.character(ikzf1_transcripts$V1))

salmon_abundances_df_ikzf1 <- as.data.frame(salmon_abundances_df_all[rownames(salmon_abundances_df_all) %in% ikzf1_transcripts_full, ])
restore_cols <- colnames(salmon_abundances_df_all)
colnames(salmon_abundances_df_ikzf1) <- restore_cols
head(salmon_abundances_df_ikzf1)
# data in data frame
trans_rows <- rownames(salmon_abundances_df_ikzf1)[grepl(pattern = "ENST*",rownames(salmon_abundances_df_ikzf1))]
total_tpm <- colSums(as.data.frame(salmon_abundances_df_ikzf1[trans_rows,]))

cutoff <- as.numeric(del47_threshold) * total_tpm
print(cutoff)
print(salmon_abundances_df_ikzf1["ENST00000331340_del47",])
print(salmon_abundances_df_ikzf1["ENST00000331340_del47",] >= cutoff)



# outputs


# write threshold test to file

thresh_results <- salmon_abundances_df_ikzf1["ENST00000331340_del47",] >= cutoff
dim(thresh_results)
print(thresh_results)
names(thresh_results) <- salmon_abundances
write.table(thresh_results,col.names=F,sep=",", file="threshold_results.csv")




# write IKZF1 transciprts  dataframe to file

#write.csv(salmon_abundances_df_ikzf1,file="output_no_t.csv")
trans <- (salmon_abundances_df_ikzf1)


write.csv(trans,file="ikzf1_tpms.csv")
