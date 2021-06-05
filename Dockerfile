FROM szabogtamas/jupy_rocker

RUN sudo apt-get update && \
    sudo apt-get install -y openjdk-11-jdk && \
    sudo apt-get install -y liblzma-dev && \
    sudo apt-get install -y libbz2-dev && \
    sudo apt-get install -y libx11-dev && \
    sudo apt-get install -y libcairo2-dev && \
    sudo apt-get install -y libxml2-dev && \
    sudo apt-get install -y libtbb2

RUN pip3 install plotly==4.14.3 && \
    pip3 install numpy>=1.15.4 && \
    pip3 install pandas>=1.0.4 && \
    pip3 install matplotlib>=2.0.0

RUN install2.r --error \
    --deps TRUE \
    devtools \
    remotes \
    rlang \
    immunarch \
    plotly \
    heatmaply \
    pheatmap \
    RColorBrewer \
    ggsci \
    ggridges \
    openxlsx \
    readxl

RUN R -e "devtools::install_github('kassambara/ggpubr')"

RUN cd \tmp && \
    wget "https://github.com/milaboratory/mixcr/releases/download/v3.0.13/mixcr-3.0.13.zip" && \
    unzip mixcr-3.0.13.zip -q -d /home/rstudio/mixcr

CMD ["/init"]
