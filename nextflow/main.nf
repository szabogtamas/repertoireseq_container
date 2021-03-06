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
    .fromFilePairs(params.input_folder + '/' + params.sample_prefix + '*_{1,2}.f*')
    .map{ [it[1][0], it[1][1], it[0]] }
    .set{ insamples }

process rnaBulkTrimmomaticPE {

    label 'manycpu'

    input:
        val adapterFileIllumina from params.adapterFileIllumina
        val manycpu from params.numcores
        tuple forward, reverse, sample from insamples

    output:
        tuple sample, "${sample}_trim_1.fastq", "${sample}_trim_2.fastq" into trimmed_fastqs

    """
    TrimmomaticPE $forward $reverse\
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
        tuple sample, "${sample}.clns" into repertoire_clns

    """
    /usr/share/mixcr/mixcr-3.0.13/mixcr analyze shotgun\
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
        tuple sample, "clones.clns" from repertoire_clns

    output:
        tuple sample, "${sample}_clones.txt" into repertoire_tables

    """
    /usr/share/mixcr/mixcr-3.0.13/mixcr exportClones clones.clns ${sample}_clones.txt
    """
} 


/*
 *        Add sample name to repertoire tables so that it can be tracked back later, after merged
 */

process addPathToTable {

    input:
        tuple sample, "clones.txt" from repertoire_tables

    output:
        file "tagged_clones.txt" into tagged_repertoire_table

    """
    R --slave -e ' \
      tb <- read.csv("clones.txt", sep="\\t", stringsAsFactors=FALSE); \
      tb["Sample_code"] <- "${sample}"; \
      write.csv(tb, "tagged_clones.txt", row.names=FALSE) \
    '
    """
} 


/*
 *        Generate report using an Rmd template
 */

Channel
    .fromPath(params.sample_metadata)
    .set{ sample_metafile }

Channel
    .fromPath(params.report_template)
    .set{ report_template }

tagged_repertoire_table
    .collectFile(name: 'merged_repertoire.txt', keepHeader: true, newLine: true)
    .set{ tagged_repertoire }

process generateReport {

    publishDir params.report_folder, mode: 'copy'

    input:
        val report_title from params.report_title
        val report_author from params.report_author
        val condition_column from params.condition_column
        val condition_order from params.condition_order
        val species from params.species
        val figformat from params.figformat
        val table_path from params.table_path
        val figure_path from params.figure_path
        val report_filename from params.report_filename
        file "template.Rmd" from report_template
        file "sample_meta.csv" from sample_metafile
        file clonotype_tab from tagged_repertoire

    output:
        file "${table_path}" into summary_tab
        file "${report_filename}" into final_report
        file "${report_filename.replaceAll(/html$/, 'Rmd')}" into report_source

    """
    cp template.Rmd "${report_filename.replaceAll(/html$/, 'Rmd')}"
    R --slave -e ' \
      rmarkdown::render( \
        "${report_filename.replaceAll(/html$/, 'Rmd')}", \
        output_file="${report_filename}", \
        params = list( \
          tagged_repertoire="${clonotype_tab}", \
          sample_metadata="sample_meta.csv", \
          condition_column="${condition_column}", \
          condition_order="${condition_order}", \
          table_path="${table_path}", \
          figure_path="${figure_path}", \
          figformat="${figformat}", \
          species="${species}" \
        ) \
      ) \
    '
    """
}
