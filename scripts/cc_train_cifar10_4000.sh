#!/bin/bash
#SBATCH --array=1-1%1
#SBATCH --mem=32000M
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --ntasks-per-node=8
#SBATCH --time=7-00:00:00
#SBATCH --mail-user=adam.tupper.1@ulaval.ca
#SBATCH --mail-type=ALL

# Check for random seed
if [ -z "$1" ]
  then
    echo "No seed supplied"
    exit 1
fi

# Print Job info
echo "Current working directory: `pwd`"
echo "Starting run at: `date`"
echo ""
echo "Job Array ID / Job ID: $SLURM_ARRAY_JOB_ID / $SLURM_JOB_ID"
echo "This is job $SLURM_ARRAY_TASK_ID out of $SLURM_ARRAY_TASK_COUNT jobs."
echo ""

module purge

# Set Weights & Biases cache and output directories
export WANDB_CACHE_DIR=$SLURM_TMPDIR/.cache/wandb
export WANDB_DIR=$scratch/wandb
mkdir -p $WANDB_CACHE_DIR
mkdir -p $WANDB_DIR

# Copy data and code to compute node
mkdir $SLURM_TMPDIR/data
tar cf $project/curriculum-learning.tar.gz $project/curriculum-learning
tar xf $project/curriculum-learning.tar.gz -C $SLURM_TMPDIR/curriculum-learning
tar xf $project/data/cifar-10-python.tar.gz -C $SLURM_TMPDIR/data

cd $SLURM_TMPDIR/curriculum-learning

# Create virtual environment
module load python/3.8.10 cuda cudnn
virtualenv --no-download $SLURM_TMPDIR/env
source $SLURM_TMPDIR/env/bin/activate
pip install --no-index --upgrade pip
pip install -r cc_requirements_extra.txt
pip install --no-index -r cc_requirements.txt

# Run training script
python main.py \
    --root_dir $scratch \
    --data_dir $SLURM_TMPDIR/data \
    --seed $1 \
    --checkpoint_epochs 100 \
    --num_labeled 400 \
    --nesterov \
    --weight-decay 0.0005 \
    --arch WRN28_2 \
    --batch_size 512 \
    --epochs 700 \
    --lr_rampdown_epochs 750 \
    --add_name WRN28_CIFAR10_AUG_MIX_SWA \
    --mixup \
    --swa