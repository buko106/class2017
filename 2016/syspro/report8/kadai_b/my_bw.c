#include<stdio.h>
#include<mpi.h>

#define BUFSIZE (1<<23)
#define RECEIVER 0
#define SENDER 1
#define NUM 1000
#define TAG 0

double dmin( double a , double b ){
  return a<b?a:b;
}

double peak( double start[NUM] , double end[NUM]){
  double time = 100000.0;
  int i;
  for( i=0 ; i<NUM ; ++i )
    time = dmin(time,end[i]-start[i]);
  return time;
}

double average( double start[NUM] , double end[NUM]){
  double time=0;
  int i;
  for( i=0 ; i<NUM ; ++i )
    time += end[i] - start[i] ;
  return time/NUM;
}

int main(int argc,char *argv[]){
  MPI_Status status;
  int myrank,processnum,i,counter;
  char buf[BUFSIZE];
  double start[NUM],end[NUM];
  MPI_Init(&argc,&argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
  MPI_Comm_size(MPI_COMM_WORLD, &processnum);
  if(myrank == SENDER){ 		/* sender */
    for( i=1 ; i<=23 ; ++i ){
      for( counter=0 ; counter<NUM ; ++counter ){
	MPI_Barrier(MPI_COMM_WORLD);
	MPI_Send(buf,(1<<i),MPI_CHAR,RECEIVER,TAG,MPI_COMM_WORLD);
      }
    }
  }else if(myrank == RECEIVER){	/* receiver */
    printf("------------------------------------------------------------------\n");
    printf(" #bytes     #iterations    BW peak[MB/sec]    BW average[MB/sec]\n");
    for( i=1 ; i<=23 ; ++i ){
      for( counter=0 ; counter<NUM ; ++counter ){
	MPI_Barrier(MPI_COMM_WORLD);
	start[counter] = MPI_Wtime();
	MPI_Recv(buf,(i<<i),MPI_CHAR,SENDER,TAG,MPI_COMM_WORLD,&status);
	end[counter]   = MPI_Wtime();
      }
      printf(" %-11d%-15d%-19.2lf%-7.2lf\n",1<<i,NUM,
	     (1<<i)/peak(start,end)/1000000.0 , (1<<i)/average(start,end)/1000000.0 );
    }
  }
  MPI_Barrier(MPI_COMM_WORLD);
  MPI_Finalize();
  return 0;
}
