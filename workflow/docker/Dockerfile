# 使用 Bioconductor 官方 image（R 4.3.1 + Bioconductor 3.20）
FROM bioconductor/bioconductor_docker:RELEASE_3_20

# 安裝 Miniconda（讓 Snakemake 的 --use-conda 可以用）
ENV CONDA_DIR=/opt/conda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p $CONDA_DIR && \
    rm /tmp/miniconda.sh && \
    $CONDA_DIR/bin/conda clean -afy
ENV PATH="$CONDA_DIR/bin:$PATH"

# TOS 驗證
RUN conda config --set channel_priority strict && \
    conda config --add channels defaults && \
    conda config --add channels conda-forge && \
    conda config --add channels bioconda && \
    conda tos accept --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --channel https://repo.anaconda.com/pkgs/r

# 安裝 Snakemake（與 Conda 獨立）
RUN pip install --upgrade pip && pip install snakemake

# 建立 GOSemSim 快取目錄，避免權限錯誤
RUN mkdir -p /home/rstudio/.local/share/GOSemSim && \
    chown -R rstudio:rstudio /home/rstudio/.local

# 安裝 CRAN 套件
RUN R -e "install.packages(c('BiocManager', 'openxlsx', 'readxl', 'data.table', 'ggplot2', 'cowplot', 'fastmatch', 'scales', 'BH', 'Cairo'), repos = 'https://cran.r-project.org')"

# 安裝 Bioconductor 套件（包含 RNA-seq + GSEA + pathview 分析所需）
RUN R -e "BiocManager::install(c( \
    'fgsea', 'edgeR', 'EnhancedVolcano', 'DESeq2', 'flextable', \
    'ComplexHeatmap', 'tximport', 'tidyverse', 'cowplot', 'biomaRt', \
    'pathview', 'DOSE', 'enrichplot', 'clusterProfiler', \
    'ReactomePA', 'HDO.db'))"