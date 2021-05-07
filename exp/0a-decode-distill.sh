#!/usr/bin/env bash
TASK=offline_mt
. ./data_path.sh
CHECKDIR=./checkpoints/${TASK}
DATABIN=${DATA}/mt/data-bin
CHECKPOINT_FILENAME=avg_best_5_checkpoint.pt
RESULT=./distilled

GENARGS="--beam 5 --max-len-a 1.2 --max-len-b 10 --lenpen 1.1 --post-process sentencepiece --tokenizer moses"

export CUDA_VISIBLE_DEVICES=1
  
python -m fairseq_cli.generate ${DATABIN} \
  --user-dir ${USERDIR} \
  --gen-subset ${SPLIT} \
  --task translation \
  --path ${CHECKDIR}/${CHECKPOINT_FILENAME} --max-tokens 80000 \
  --model-overrides '{"load_pretrained_encoder_from": None}' \
  --results-path ${RESULT} \
  ${GENARGS}