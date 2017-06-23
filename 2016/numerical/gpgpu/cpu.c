#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#define XSIZE 1024
#define YSIZE 1024
#define ITERATION 100
#define NUMBER(n,i,j) (((n)&0x1? XSIZE*YSIZE :0) + (i)*YSIZE + (j))

void debug_print( float* u ){
  int i,j;
  for( i=0 ; i<XSIZE ; ++i ){
    for( j=0 ; j<YSIZE ; ++j ){
      printf("%.1e ",u[NUMBER(0,i,j)]);
    }
    printf("\n");
  }
  return ;
}

int main(){
  
  float r = 0.05;
  float* u = (float*)malloc(2*XSIZE*YSIZE*sizeof(float));
  int i,j,n;
  // initialize
  for( i = 0 ; i < XSIZE ; ++i ){
    for( j = 0 ; j < YSIZE ; ++j ){
      u[NUMBER(0,i,j)] = ( i==0 || i==XSIZE-1 || j==0 || j==YSIZE-1 ? 0.0 : 1.0 );
    }
  }

  // get time 
  struct timeval t_begin,t_end;
  gettimeofday(&t_begin,NULL);
  
  for( n = 0 ; n < ITERATION ; ++n ){
    for( i = 1 ; i <= XSIZE-2 ; ++i ){
      for( j = 1 ; j <= YSIZE-2 ; ++j ){
        u[NUMBER(n+1,i,j)] 
          = (1.0-4.0*r)*u[NUMBER(n,i,j)] 
          + r*(u[NUMBER(n,i+1,j)]+u[NUMBER(n,i-1,j)]+u[NUMBER(n,i,j+1)]+u[NUMBER(n,i,j-1)]);
      }
    }
  }
  

  // print time
  gettimeofday(&t_end,NULL);
  double elapsed = (double)(t_end.tv_sec-t_begin.tv_sec) + (double)(t_end.tv_usec-t_begin.tv_usec) / (1000.0*1000.0);
  printf("Elapsed time = %lf(sec)\n", elapsed );
  printf("FLOPS = %g\n" , 6.0*ITERATION*(XSIZE-2)*(YSIZE-2)/elapsed );
  // debug_print(u);
  return 0;
}
