#!/bin/bash
#SBATCH --array=1-1%1
#SBATCH --mem=32000M
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --ntasks-per-node=8
#SBATCH --time=1-00:00:00
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
echo "Run ID: CL_M_$SLURM_ARRAY_JOB_ID"
echo "Seed: $1"
echo ""
echo "Job Array ID / Job ID: $SLURM_ARRAY_JOB_ID / $SLURM_JOB_ID"
echo "This is job $SLURM_ARRAY_TASK_ID out of $SLURM_ARRAY_TASK_COUNT jobs."
echo ""

module purge

# Copy data and code to compute node
mkdir $SLURM_TMPDIR/data
cd $project
tar cf curriculum-labeling.tar.gz curriculum-labeling
tar xf curriculum-labeling.tar.gz -C $SLURM_TMPDIR
tar xf data/cifar-10-python.tar.gz -C $SLURM_TMPDIR/data

cd $SLURM_TMPDIR/curriculum-labeling

# Activate virtual environment
# (cannot be created on Narval compute nodes because of extra dependencies)
module load python/3.8.10 cuda cudnn
source ~/venvs/cl/bin/activate

# Run training script
python main.py \
    --no-resets \
    --root_dir $scratch \
    --data_dir $SLURM_TMPDIR/data \
    --seed $1 \
    --checkpoint_epochs 100 \
    --num_labeled 25 \
    --nesterov \
    --weight-decay 0.0005 \
    --arch WRN28_2 \
    --batch_size 512 \
    --epochs 200 \
    --lr_rampdown_epochs 1200 \
    --add_name WRN28_CIFAR10_250_$1_CL_M_$SLURM_ARRAY_JOB_ID \
    --augPolicy 1