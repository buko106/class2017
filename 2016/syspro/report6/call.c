#include<unistd.h>
#include<sys/types.h>
#include<sys/wait.h>
#include<stdio.h>
#include<stdlib.h>

int main(int argc,char *argv[],char *envp[]){
  if(argc<2){
    printf("USAGE:call PROGRAM [OPTION...]");
    return -1;
  }
  
  int pid,status;
  

  if( 0 == ( pid = fork() ) ){  /* child */
    execve( argv[1] , &argv[1] , envp );
    perror(argv[1]);
    exit(1);
  }else{                        /* parent */
    waitpid( pid , &status , WUNTRACED );
  }
  
  return 0;
}
