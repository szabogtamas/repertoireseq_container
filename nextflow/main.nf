/*
        *Trim Paired End reads with Trimmomatic
*/
Channel
    .from([params.forward_fastqs, params.reverse_fastqs, params.sample_ids].transpose())
    .map{[params.input_folder + '/' + it[0], params.input_folder + '/' + it[1], it[2]]}
    .set{insamples}

process rnaBulkTrimmomaticPE {

    label 'manycpu'

    input:
        val adapterFileIllumina from params.adapterFileIllumina
        val manycpu from params.manycpu
        tuple forward, reverse, sample from insamples

    output:
        tuple sample, "${sample}_trim_1.fastq", "${sample}_trim_2.fastq" into trimmed_fastqs

    """
    trimmomatic PE $forward $reverse\
    ${sample}_trim_1.fastq ${sample}_forward_unpaired.fastq\
    ${sample}_trim_2.fastq ${sample}_reverse_unpaired.fastq\
    ILLUMINACLIP:$adapterFileIllumina:2:30:10:8:keepBothReads LEADING:3 TRAILING:3 MINLEN:36\
    -threads $manycpu

    """
} 

