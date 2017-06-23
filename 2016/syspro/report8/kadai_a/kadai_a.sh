#PBS -j oe
#PBS -l walltime=0:03:00
#PBS -l nodes=4:ppn=8
cd $PBS_O_WORKDIR
ib_read_bw -a n01
