#include <stdio.h>
#include <pthread.h>

#define NUM 1000
int count=0;


void *func(void *p){
  int i;
  for(i=0;i<1000;++i){
    ++count;
  }
  return NULL;
}

int main(){
  pthread_t pthread[NUM];
  int i;
  for(i=0;i<NUM;++i){
    pthread_create(&pthread[i],NULL,func,NULL);
  }
  for(i=0;i<NUM;++i){
    pthread_join(pthread[i],NULL);
  }
  printf("count=%d\n",count);
  return 0;
}
