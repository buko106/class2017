#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>

#define N_BB 1
#define N_PRODUCER 10
#define N_CONSUMER 10
#define N_ITEM 5

int bb_buf[N_BB];
int bb_count;
int bb_in,bb_out;
int bb_wait_get,bb_wait_put;
pthread_mutex_t bb_mutex=PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t bb_empty=PTHREAD_COND_INITIALIZER;
pthread_cond_t bb_full=PTHREAD_COND_INITIALIZER;

void bb_init(){
  bb_count=0;
  bb_in=0;
  bb_out=0;
  bb_wait_get=0;
  bb_wait_put=0;
  return;
}

void bb_put(int val){
  pthread_mutex_lock(&bb_mutex);
 loop:
  if(bb_count<N_BB){
    bb_buf[bb_in]=val;
    ++bb_count;
    bb_in = (bb_in+1)%N_BB;
    if(bb_wait_get>0)
      pthread_cond_signal(&bb_empty);
  }else{
    ++bb_wait_put;
    pthread_cond_wait(&bb_full,&bb_mutex);
    --bb_wait_put;
    goto loop;
  }
  pthread_mutex_unlock(&bb_mutex);
  return;
}

int bb_get(void){
  int val;
  pthread_mutex_lock(&bb_mutex);
 loop:
  if(bb_count>0){
    val=bb_buf[bb_out];
    --bb_count;
    bb_out = (bb_out+1)%N_BB;
    if(bb_wait_put>0)
      pthread_cond_signal(&bb_full);
  }else{
    ++bb_wait_get;
    pthread_cond_wait(&bb_empty,&bb_mutex);
    --bb_wait_get;
    goto loop;
  }
  pthread_mutex_unlock(&bb_mutex);
  return val;
}

void *producer(void* arg){
  int i,val;
  int num=(N_CONSUMER*N_ITEM)/N_PRODUCER;
  for(i=0;i<num;++i){
    val = i + *(int*)arg*num;
    bb_put(val);
    printf("bb_put[%d](%d)\n",*(int*)arg,val);
  }
  return 0;
}

void *consumer(void* arg){
  int i;
  for(i=0;i<N_ITEM;++i)
    printf("bb_get[%d]() -> %d\n",*(int*)arg,bb_get());
  return 0;
}

int main(){
  int i;
  pthread_t pthread[N_PRODUCER+N_CONSUMER];
  int id[N_PRODUCER+N_CONSUMER];
  bb_init();
  for(i=0;i<N_PRODUCER+N_CONSUMER;++i)
    id[i]=i;
  
  for(i=0;i<N_PRODUCER;++i){
    if(0 != pthread_create(&pthread[i],NULL,producer,&id[i])){
      perror("Can not make producer");
      return 1;
    }
  }
  for(i=0;i<N_CONSUMER;++i){
    if(0 != pthread_create(&pthread[i+N_PRODUCER],NULL,consumer,&id[i])){
      perror("Can not make consumer");
      return 1;
    }
  }
  for(i=0;i<N_PRODUCER+N_CONSUMER;++i){
    if(0 != pthread_join(pthread[i],NULL)){
      perror("pthread_join");
      return 1;
    }
  }
  printf("bb_count=%d\nbb_in=%d\nbb_out=%d\nbb_wait_put=%d\nbb_wait_get=%d\n",bb_count,bb_in,bb_out,bb_wait_put,bb_wait_get);
  return 0;
}
