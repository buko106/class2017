#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>

double innerproduct( double * , double * , uint64_t );

#define SIZE 20000
double a[SIZE],b[SIZE];

int main(){
  uint64_t n = SIZE;
  int i;
  double inner ;
  struct timeval before,after;
  srand(time(NULL));
  for(i=0;i<n;++i){
    a[i] = rand();
    b[i] = rand();
  }
  gettimeofday(&before,NULL);
  inner = innerproduct(a,b,n);
  gettimeofday(&after,NULL);
  
  printf("N=%llu\nans=%.10le\ntime(s)=%.10le\n",(unsigned long long)n,inner
         ,(double)(after.tv_sec-before.tv_sec)
         +(after.tv_usec-before.tv_usec)/1000.0/1000.0);
  return 0;
}
