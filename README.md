# repertoireseq_container

A docker container with tools to help analyze Immune Repertoire from (currently bulk) RNAseq.

## Tools integrated

Currently MiXCR (https://github.com/milaboratory/mixcr), Immunarch (https://immunarch.com/) and some components of the Imcantation framework (https://immcantation.readthedocs.io/) are added.
Development is now in progress.

## Usage

This is a container designed to be used as part of a Nextflow pipeline. 
Additionally, nextflow can also be run inside the contatiner, although this is recommended for testing purposes only.  

If the measured data is in the `input_data` folder of the current directory (alternatively, using test data in `test_datas/imulated_input`), a basic report can be generated issuing the following command:

```
docker run -it -v $PWD:/home/rstudio/local_files \
  szabogtamas/repertoireseq_container \
  nextflow run /home/rstudio/repo_files/nextflow/main.nf \
  --input_folder /home/rstudio/local_files/input_data \
  --report_filename "my_test_repertoire_report.pdf" \
  --report_title "A test report" \
  --report_author "Me"
```

In addition to the generated interactive html report, some major figures will also be exported in pdf format, to the  `figures` folder. Assembly reports and a raw repertoire table will also be generated.

## Test data source

A simulated dataset, derived from Ig sequences published by [Goldstein et al.](https://pubmed.ncbi.nlm.nih.gov/31428692/) is available in test_data/simulated_input folder.