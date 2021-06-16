FROM rocker/rstudio:3.6.3

RUN sudo apt-get update
RUN sudo apt-get install -y openjdk-11-jdk
RUN sudo apt-get install -y liblzma-dev
RUN sudo apt-get install -y libbz2-dev
RUN sudo apt-get install -y libx11-dev
RUN sudo apt-get install -y libcairo2-dev
RUN sudo apt-get install -y libxml2-dev
RUN sudo apt-get install -y libtbb2
RUN sudo apt-get install -y libglpk-dev
RUN sudo apt-get install -y libpq-dev
RUN sudo apt-get install -y libgdal-dev
RUN sudo apt-get install -y libssl-dev
RUN sudo apt-get install -y libgeos-dev
RUN sudo apt-get install -y libudunits2-dev
RUN sudo apt-get install -y libmagick++-dev
RUN sudo apt-get install -y phylip

RUN install2.r --error \
    --deps TRUE \
    devtools
RUN install2.r --error \
    --deps TRUE \
    remotes
RUN install2.r --error \
    --deps TRUE \
    rlang
RUN install2.r --error \
    --deps TRUE \
    Rcpp
RUN install2.r --error \
    --deps TRUE \
    ggpubr
RUN install2.r --error \
    --deps TRUE \
    plotly
RUN install2.r --error \
    --deps TRUE \
    heatmaply
RUN install2.r --error \
    --deps TRUE \
    pheatmap
RUN install2.r --error \
    --deps TRUE \
    RColorBrewer
RUN install2.r --error \
    --deps TRUE \
    ggsci
RUN install2.r --error \
    --deps TRUE \
    ggridges
RUN install2.r --error \
    --deps TRUE \
    openxlsx
RUN install2.r --error \
    --deps TRUE \
    readxl

RUN R -e "BiocManager::install('immunarch')" && \
    R -e "BiocManager::install('shazam')" && \
    R -e "BiocManager::install('alakazam')"

RUN cd \tmp && \
    wget "https://github.com/milaboratory/mixcr/releases/download/v3.0.13/mixcr-3.0.13.zip" && \
    unzip mixcr-3.0.13.zip -d /home/rstudio/mixcr
ENV PATH="/home/rstudio/mixcr/mixcr-3.0.13:${PATH}"

CMD ["/init"]
