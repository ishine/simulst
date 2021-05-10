#!/usr/bin/env bash
TASK=wait_9
SPLIT=dev #tst-COMMON
EXP=../exp
. ${EXP}/data_path.sh
CONF=$DATA/config_st.yaml
CHECKDIR=${EXP}/checkpoints/${TASK}
AVG=true

GENARGS="--beam 1 --max-len-a 1.2 --max-len-b 10 --lenpen 1.1"

export CUDA_VISIBLE_DEVICES=0

if [[ $AVG == "true" ]]; then
  CHECKPOINT_FILENAME=avg_best_5_checkpoint.pt
  python ../scripts/average_checkpoints.py \
    --inputs ${CHECKDIR} --num-best-checkpoints 5 \
    --output "${CHECKDIR}/${CHECKPOINT_FILENAME}"
else
  CHECKPOINT_FILENAME=checkpoint_best.pt
fi

python -m fairseq_cli.generate ${DATA} --user-dir ${USERDIR} \
  --config-yaml ${CONF} --gen-subset ${SPLIT}_st \
  --task speech_to_text_infer --inference-config-yaml ../exp/infer_simulst.yaml \
  --path ${CHECKDIR}/${CHECKPOINT_FILENAME} --max-tokens 80000 \
  --model-overrides '{"load_pretrained_encoder_from": None}' \
  ${GENARGS}