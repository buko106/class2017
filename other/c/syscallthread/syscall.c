#define _GNU_SOURCE
#include <sched.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#define NUM 1000
#define STACK_SIZE (1024*4)
int count=0;

int func(void *p){
  int i;
  for(i=0;i<1000;++i){
    ++count;
  }
  return 0;
}

int main(){
  char *stack[NUM];
  char *stackTop;
  pid_t pid[NUM];
  int i;

  for(i=0;i<NUM;++i){
    stack[i] = malloc(STACK_SIZE);
    if(stack[i]==NULL){
      perror("malloc");
      return -1;
    }
    stackTop=stack[i]+STACK_SIZE;
    pid[i]=clone(func,stackTop,CLONE_VM|SIGCHLD,NULL);
    /* printf("%d\n",pid[i]); */
    if(pid[i]==-1){
      perror("clone");
      return -1;
    }
  }
  for(i=0;i<NUM;++i){
    if(waitpid(pid[i],NULL,0)==-1){
      perror("waitpid");
      return -1;
    }
  }
  printf("count=%d\n",count);
  for(i=0;i<NUM;++i)
    free(stack[i]);
  return 0;
}

/* countを10回インクリメントする関数を動かすスレッドをpthreadとcloneを使った２種類の方法で生成した。cloneでスレッドを生成するにはCLONE_VMで同じメモリ空間上で走るように指定する必要がある、またシグナルとしてSIGCHLDを指定することでwaitpidで終了を待てるようになる。 */
