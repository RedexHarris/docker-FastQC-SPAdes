#!/bin/bash

DATA_DIR="/data"
RESULTS_DIR="/results/fastqc"

echo "=== 运行FastQC质控 ==="
fastqc ${DATA_DIR}/XJ_S1_L001_R1.fastq.gz \
       ${DATA_DIR}/XJ_S1_L001_R2.fastq.gz \
       -o ${RESULTS_DIR}

echo "=== FastQC结果 ==="
ls -lh ${RESULT_DIR}