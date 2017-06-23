#PBS -j oe
#PBS -l walltime=0:03:00
#PBS -l nodes=2:ppn=1
cd $PBS_O_WORKDIR
mpirun -np 2 ./my_bw
