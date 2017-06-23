#include<unistd.h>
#include <fcntl.h>
#include<sys/types.h>
#include<sys/wait.h>
#include<sys/stat.h>
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include"parse.h"

#define perror_exit(msg) do{perror(msg);exit(1);}while(0)

void print_job_list(job*);

int main(int argc,char *argv[],char *envp[]){
  int pid[LINELEN],status[LINELEN];
  int count,i,in_fd,out_fd;
  char command[LINELEN];
  job *jobs;
  process *proc;
  int fd[LINELEN][2];
  
  while(get_line(command,LINELEN)){
    
    if( NULL == (jobs = parse_line(command) ) )continue;
    //print_job_list(jobs);
    proc = jobs->process_list;
    count = 0;
    
    if( 0 == strcmp("exit",proc->program_name)
        && NULL == proc->next) exit(0);

    while( NULL != proc ){
      if( -1 == pipe(fd[count]) ) perror_exit("pipe");
      if( 0 == ( pid[count] = fork() ) ){/* child */
        if( 0 < count ){
          dup2(fd[count-1][0],0);
        } /* 先頭でないなら入力を１個前のパイプにつなぐ */
        if( NULL != proc->next ){
          dup2(fd[count][1],1);
        } /* 末尾でないなら出力をパイプにつなぐ */
        for(i=0;i<=count;++i){
          close(fd[i][0]);
          close(fd[i][1]);
        } /* もう使わないのでパイプは閉じる */

        if( NULL != proc->input_redirection ){
          in_fd = open(proc->input_redirection,O_RDONLY);
          if( -1 == in_fd )perror_exit(proc->input_redirection);
          dup2(in_fd,0);
        }
        
        if( NULL != proc->output_redirection ){
          if( TRUNC == proc->output_option )
            out_fd = open(proc->output_redirection,O_WRONLY|O_TRUNC |O_CREAT,
                          S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH);
          else /* APPEND ==  ...*/
            out_fd = open(proc->output_redirection,O_WRONLY|O_APPEND|O_CREAT,
                          S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH);
          if( -1 == out_fd)perror_exit(proc->output_redirection);
          dup2(out_fd,1);
        }

        execve( proc->program_name , proc->argument_list , envp );
        perror_exit(proc->program_name);
      } /* end child */
      /* parent */
      
      proc = proc->next;
      ++count;
    }
    for(i=0;i<count;++i){
      close(fd[i][0]);
      close(fd[i][1]);
    } /* シェルでパイプは使わないので全部閉じる */
    for(i=0;i<count;++i){
      waitpid( pid[i] , &status[i] , WUNTRACED );
    }
    free_job(jobs);
  }
  
  return 0;
}
