#!/bin/bash

DATA_DIR="/data"
RESULTS_DIR="/results/spades"

echo "=== 运行 SPAdes 拼接 ==="
spades.py --isolate \
          --pe1-1 ${DATA_DIR}/XJ_S1_L001_R1.fastq.gz \
          --pe1-2 ${DATA_DIR}/XJ_S1_L001_R2.fastq.gz \
          -o ${RESULTS_DIR} \
          -t 4

echo "=== SPAdes 结果 ==="
ls -lh ${RESULTS_DIR}/contigs.fasta