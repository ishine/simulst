# Simultaneous Speech Translation
Proposed: Learning to translate monotonically by optimal transport.

## Setup

1. Install fairseq
```bash
git clone https://github.com/pytorch/fairseq.git
cd fairseq
git checkout 8b861be
python setup.py build_ext --inplace
```
2. (Optional) [Install](docs/apex_installation.md) apex for faster mixed precision (fp16) training.
3. Install dependencies
```bash
pip install -r requirements.txt
```

## Data Preparation
This section introduces the data preparation for training and evaluation. Following will be based on MuST-C.

1. [Download](https://ict.fbk.eu/must-c/) and unpack the package.
```bash
cd ${DATA_ROOT}
tar -zxvf MUSTC_v1.0_en-de.tar.gz
```
2. In `DATA/get_mustc.sh`, set `DATA_ROOT` to the path of speech data (the directory of previous step).
3. Preprocess data with
```bash
cd DATA
bash get_mustc.sh
```
The output manifest files should appear under `${DATA_ROOT}/en-de/`. 

Configure environment and path in `exp/data_path.sh` before training:
```bash
export SRC=en
export TGT=de
export DATA=/media/george/Data/mustc/${SRC}-${TGT}

FAIRSEQ=`realpath ../fairseq`
USERDIR=`realpath ../simultaneous_translation`
export PYTHONPATH="$FAIRSEQ:$PYTHONPATH"

# If you have venv, add this line to use it
# source ~/envs/fair/bin/activate
```

## Sequence-Level KD
We need a machine translation model as teacher for sequence-KD. 

### Prepare data for MT
```bash
cd DATA
bash get_data_mt.sh
```
### Train MT Model
The following command will train the mt model with transcription and translation
```bash
cd exp
bash 0-distill.sh
```
Average the checkpoints to get a better model
```bash
CHECKDIR=checkpoints/offline_mt
CHECKPOINT_FILENAME=avg_best_5_checkpoint.pt
python ../scripts/average_checkpoints.py \
  --inputs ${CHECKDIR} --num-best-checkpoints 5 \
  --output "${CHECKDIR}/${CHECKPOINT_FILENAME}"
```
To distill the training set, run 
```bash
bash 0a-decode-distill.sh # generate prediction at ./distilled/train_st.tsv
bash 0b-create-distill-tsv.sh # generate distillation data at ${DATA_ROOT}/distill_${lang}.tsv
```

## ASR Pretraining
We also need an offline ASR model to initialize our ST models. Note that the encoder of this model should be causal.
```bash
bash 1-offline_asr.sh # autoregressive ASR
```
A pretrained ASR for `s2t_transformer_s` can be downloaded [here](https://onedrive.live.com/download?cid=3E549F3B24B238B4&resid=3E549F3B24B238B4%215970&authkey=AArXboES4OmbqAc)


## Vanilla wait-k
We can now train vanilla wait-k ST model as a baseline. To do this, run
<!-- > **_NOTE:_**  to train with the distillation set, set `dataset.train_subset` to `distill_${lang}` in the script. -->
```bash
bash 2-vanilla_wait_k.sh
```
### Pretrained models
|DATA|arch|en-es|en-de|
|-|-|-|-|
|wait-1||||
|wait-9||||


## Offline Evaluation (BLEU only)
## Online Evaluation (SimulEval)
Install [SimulEval](docs/extra_installation.md).