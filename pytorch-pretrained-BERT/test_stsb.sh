# Configures
export TASK_NAME=STS-B
export EPOCH=0
export CASED=uncased
export LARGE=large
export LR=5e-5

INIT_DIR=model_checkpoints/STS-B-${LARGE}-${CASED}
GLUE_DIR=glue_data

python examples/run_classifier.py \
  --task_name $TASK_NAME \
  --do_lower_case \
  --do_eval \
  --do_test \
  --bert_model bert-$LARGE-$CASED \
  --data_dir $GLUE_DIR/$TASK_NAME \
  --max_seq_length 128 \
  --train_batch_size 32 \
  --learning_rate $LR \
  --num_train_epochs $EPOCH \
  --output_dir $INIT_DIR

# Configures
export CASED=cased

INIT_DIR=model_checkoints/STS-B-${LARGE}-${CASED}
GLUE_DIR=glue_data

python examples/run_classifier.py \
  --task_name $TASK_NAME \
  --do_eval \
  --do_test \
  --bert_model bert-$LARGE-$CASED \
  --data_dir $GLUE_DIR/$TASK_NAME \
  --max_seq_length 128 \
  --train_batch_size 32 \
  --learning_rate $LR \
  --num_train_epochs $EPOCH \
  --output_dir $INIT_DIR