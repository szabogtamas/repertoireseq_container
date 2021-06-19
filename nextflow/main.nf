#!/usr/bin/env nextflow

////////////////////////////////////////////////////////////////////////////
//                                                                        //
//  Take a quick look at BCR repertoire from bulk RNAseq                  //
//                                                                        //
////////////////////////////////////////////////////////////////////////////


/*
 *        Trim Paired End reads with Trimmomatic
 */

Channel
    .from([params.forward_fastqs, params.reverse_fastqs, params.sample_ids].transpose())
    .map{[params.input_folder + '/' + it[0], params.input_folder + '/' + it[1], it[2]]}
    .set{ insamples }

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


/*
 *        Use MiXCR to reconstruct BCR repertoire
 */

process reconstructBCRepertoireMiXCR {

    publishDir params.clonotype_dir, pattern: '*.txt', mode: 'copy'

    input:
        val species_alias from params.species_alias
        tuple sample, "${sample}_trim_1.fastq", "${sample}_trim_2.fastq" from trimmed_fastqs

    output:
        file "${sample}_repertoire.txt" into repertoire_reports
        tuple sample, ${sample}_clones.clna into repertoire_clna

    """
    mixcr analyze shotgun\
    --only-productive\
    --starting-material rna\
    --receptor-type bcr\
    --species $species_alias\
    --report ${sample}_repertoire.txt\
    ${sample}_trim_1.fastq ${sample}_trim_2.fastq\
    $sample
    """
} 


/*
 *        Merge reconstructed clontype chains from MiXCR to a format friendlier to Immunach
 */

process mergeChainedMiXCR {

    publishDir params.clonotype_dir, pattern: '*.txt', mode: 'copy'

    input:
        tuple sample, "clones.clna" from repertoire_clna

    output:
        file "${sample}_clones.txt" into repertoire_tables

    """
    mixcr exportClones clones.clna ${sample}_clones.txt
    """
} 


/*
 *        Add sample name to repertoire tables so that it can be tracked back later, after merged
 */

process addPathToTable {

    input:
        tuple sample, "clones.txt" from repertoire_tables

    output:
        file "tagged_clones.txt)" into tagged_repertoire_table

    """
    R --slave -e 'tb <- read.csv("clones.txt", stringsAsFactors=FALSE); tb["Sample_code"] <- ${sample}; write.csv(tb, tagged_clones.txt)'
    """
} 


/*
 *        Generate report using an Rmd template
 */

tagged_repertoire_table
    .collectFile(name: 'merged_repertoire.txt', keepHeader: true, newLine: true)
    .set{ tagged_repertoire }

process generateReport {

    publishDir params.report_dir, pattern: '*.html', mode: 'copy'

    input:
        val report_template from params.report_template
        val report_filename from params.report_filename
        val report_title from params.report_title
        val report_author from params.report_author
        val report_condition_column from params.condition_column
        val species from params.species
        file clonotype_tab from tagged_repertoire
        file sample_meta from params.sample_metadata

    output:
        file reperoire_report.html into final_report

    """
    R --slave -e 'rmarkdown::render("${report_template}", "${report_filename}", params = list(clonotype_tab=${clonotype_tab}, sample_metadata=${sample_metadata}, condition_column=${condition_column}, species=${species}'
    """
} 
