#!/bin/bash
# Launch Slurm jobs for training with curriculum labeling for all additional
# seeds and all levels of supervision on CIFAR-10.

seeds=(663829 225659 497412 865115 830930 750366 232841 296628 973089)

for seed in "${seeds[@]}"
do
    sbatch cc_train_cl_cifar10_4000.sh $seed $(cat /proc/sys/kernel/random/uuid)
    sbatch cc_train_cl_cifar10_2000.sh $seed $(cat /proc/sys/kernel/random/uuid)
    sbatch cc_train_cl_cifar10_1000.sh $seed $(cat /proc/sys/kernel/random/uuid)
    sbatch cc_train_cl_cifar10_500.sh $seed $(cat /proc/sys/kernel/random/uuid)
    sbatch cc_train_cl_cifar10_250.sh $seed $(cat /proc/sys/kernel/random/uuid)
done