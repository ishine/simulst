#!/usr/bin/env bash
. ./data_path.sh
DECODED=./distilled/generate-test.txt
TRAIN=${DATA}/train_st.tsv
OUT=${DATA}/train_distill.tsv

# grep -E "D-[0-9]+" ${DECODED} | head
python ../DATA/create_distillation_tsv.py \
    --moses-detok ${TGT} \
    --train-file ${TRAIN} \
    --distill-file ${DECODED} \
    --out-file ${OUT}