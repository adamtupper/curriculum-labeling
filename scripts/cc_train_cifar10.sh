#!/bin/bash
#SBATCH --array=831,832,727%1
#SBATCH --mem=32000M
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --ntasks-per-node=8
#SBATCH --time=24:00:00
#SBATCH --mail-user=adam.tupper.1@ulaval.ca
#SBATCH --mail-type=ALL

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
pip install --no-index -r cc_requirements.txt
pip install -r cc_requirements_extra.txt

# Run training script
# TODO: Call training script