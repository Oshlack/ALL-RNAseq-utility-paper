salmon_custom_quant = {
    //Generate STAR genome index
    doc "Quantify with Salmon"
def base_outdir = "salmon_out/" + branch.name 
    output.dir = base_outdir 


  from("*.fastq.gz") {
        produce ("quant.sf") {

            exec """
               module load salmon && salmon quant --validateMappings  --dumpEq -i $SALMONIDX -l A -1 $input1 -2 $input2 -p $NTHREADS -o ${output.dir} 

            ""","salmonquant"
    }
}
}

collate_tpm = {

def base_outdir = "salmon_out/" + branch.name
    output.dir = base_outdir 


  from("quant.sf") {
        produce ("ikzf1_tpm.csv") {

 	exec """
		cat ${input} |awk '{print \$1 "," \$4}' |grep -f ikzf1_transcripts.txt  > $output
	"""

}

}
}


filter_thresholds = {



  from("quant.sf") {
produce ("ikzf1_tpms.csv","threshold_results.csv") {

def inputs_join =   inputs.join(':')
        exec """

        module load R &&  R --vanilla --args --del47 ${DEL47} --files ${inputs_join} < filter_del47.R  > $output


"""

}
}
}




filter_tpm = {

def base_outdir = "salmon_out/" + branch.name
    output.dir = base_outdir 


        from ("ikzf1_tpm.csv") {
        produce ("ikzf1_tpm_results.csv") {


exec """

	cat $input | sort -t, -nrk2 |head -n1 > $output

"""
}}
}



