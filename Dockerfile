FROM rocker/rstudio:3.6.3

RUN sudo apt-get update && \
    sudo apt-get install -y openjdk-11-jdk && \
    sudo apt-get install -y liblzma-dev && \
    sudo apt-get install -y libbz2-dev && \
    sudo apt-get install -y libx11-dev && \
    sudo apt-get install -y libcairo2-dev && \
    sudo apt-get install -y libxml2-dev && \
    sudo apt-get install -y libtbb2 && \
    sudo apt-get install -y libglpk-dev && \
    sudo apt-get install -y libpq-dev && \
    sudo apt-get install -y libgdal-dev && \
    sudo apt-get install -y libssl-dev && \
    sudo apt-get install -y libgeos-dev && \
    sudo apt-get install -y libudunits2-dev && \
    sudo apt-get install -y libmagick++-dev && \
    sudo apt-get install -y phylip

RUN install2.r --error \
    --deps TRUE \
    devtools \
    remotes \
    rlang \
    Rcpp \
    ggpubr \
    plotly \
    heatmaply \
    pheatmap \
    RColorBrewer \
    ggsci \
    ggridges \
    openxlsx \
    readxl

RUN R -e "BiocManager::install('shazam')" && \
    R -e "BiocManager::install('alakazam')"

RUN R -e "devtools::install_github('immunomind/immunarch')"

RUN cd \tmp && \
    wget "https://github.com/milaboratory/mixcr/releases/download/v3.0.13/mixcr-3.0.13.zip" && \
    unzip mixcr-3.0.13.zip -d /home/rstudio/mixcr
ENV PATH="/home/rstudio/mixcr/mixcr-3.0.13:${PATH}"

ADD ./ /home/rstudio/repo_files

CMD ["/init"]
