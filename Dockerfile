FROM szabogtamas/jupy_rocker

RUN sudo apt-get update -y
RUN sudo apt-get install -y libx11-dev
RUN sudo apt-get install -y libcairo2-dev
RUN sudo apt-get install -y libxml2-dev
RUN sudo apt-get install -y libtbb2

RUN pip3 install plotly==4.14.3
RUN pip3 install numpy>=1.15.4
RUN pip3 install pandas>=1.0.4
RUN pip3 install matplotlib>=2.0.0

RUN install2.r --error \
    --deps TRUE \
    devtools \
    remotes \
    rlang \
    plotly \
    heatmaply \
    pheatmap \
    RColorBrewer \
    ggsci \
    ggridges \
    openxlsx \
    readxl

RUN R -e "devtools::install_github('kassambara/ggpubr')"

CMD ["/init"]
