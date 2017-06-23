#include<unistd.h>
#include<fcntl.h>
#include<sys/types.h>
#include<sys/wait.h>
#include<sys/stat.h>
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<errno.h>
#include<signal.h>
#include"parse.h"

#define perror_exit(msg) do{perror(msg);exit(1);}while(0)

void print_job_list(job*);
void print_all_job(job*);
void run(job*,job**);
void fg(job**,int);
void bg(job*,int);
void init();
void init_child();
void check_bg(job**);
void print_a_job(job*);

extern int errno;

int main(int argc,char *argv[],char *envp[]){
  int pid[LINELEN];
  int count,i,in_fd,out_fd;
  char command[LINELEN];
  process *proc;
  int fd[LINELEN][2];
  job *jobs,*bg_jobs=NULL;
  
  init();

  while(get_line(command,LINELEN)){
    
    if( NULL == (jobs = parse_line(command) ) ){
      check_bg(&bg_jobs);
      continue;
    }
    //print_job_list(jobs);
    proc = jobs->process_list;
    count = 0 ;
    
    if( 0 == strcmp("exit",proc->program_name)
        && NULL == proc->next) exit(0);
    if( 0 == strcmp("jobs",proc->program_name)
        && NULL == proc->next){
      print_all_job(bg_jobs);
      check_bg(&bg_jobs);
      free_job(jobs);
      continue;
    }
    if( 0 == strcmp("bg",proc->program_name)
        && NULL == proc->next){
      int id;
      if( NULL == proc->argument_list[1] )
        id = 0;
      else
        id = atoi(proc->argument_list[1] );
      bg(bg_jobs,id);
      free_job(jobs);
      continue;
    }
    if( 0 == strcmp("fg",proc->program_name) /* fgの処理 */
        && NULL == proc->next){
      if( NULL == bg_jobs ){
        printf("fg: No background job\n");
        continue;
      }
      int id;
      if( proc->argument_list[1]==NULL )
        id = 0;
      else
        id = atoi(proc->argument_list[1]);
      
      fg(&bg_jobs,id);
      free_job(jobs);
      check_bg(&bg_jobs);
      continue;
    }

    while( NULL != proc ){
      if( -1 == pipe(fd[count]) ) perror_exit("pipe");
      if( 0 == ( pid[count] = fork() ) ){/* child */
        if( 0 == count ){
          if( -1 == setpgid( 0 , 0 )) perror_exit("setpgid");
        }else if( -1 == setpgid( 0 , pid[0] )) perror_exit("setpgid");

        //printf("I'm [%d][%d]%s(count=%d)\n",getpid(),getpgrp(),proc->program_name,count);
        init_child();

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
          dup2(in_fd,STDIN_FILENO);
        }
        
        if( NULL != proc->output_redirection ){
          if( TRUNC == proc->output_option )
            out_fd = open(proc->output_redirection,O_WRONLY|O_TRUNC |O_CREAT,S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH);
          else /* APPEND ==  ...*/
            out_fd = open(proc->output_redirection,O_WRONLY|O_APPEND|O_CREAT,S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH);
          if( -1 == out_fd)perror_exit(proc->output_redirection);
          dup2(out_fd,STDOUT_FILENO);
        }

        if( -1 == execve( proc->program_name , proc->argument_list , envp ) )
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
    
    jobs->pgid = pid[0];        /* process group id を格納 */
    for( i = 0,proc=jobs->process_list ; i < count ; ++i ){
      proc->pid = pid[i];
      //printf("proc->pid = pid[i] = %d\n",proc->pid);
      proc = proc->next;
    } /* process idを格納 */
    
    if( FOREGROUND == jobs->mode ){   /* foregroundの処理 */
      print_a_job(jobs);
      run(jobs,&bg_jobs);
    }else if( BACKGROUND == jobs->mode ){ /* backgroundの処理 */
      jobs->next = bg_jobs;
      bg_jobs = jobs;           /* bj_jobs(実質スタック)に積む */
    }
    
    check_bg(&bg_jobs);
  }
  return 0;
}

void print_all_job(job* jobs){
  for( ; NULL != jobs ; jobs = jobs->next )
    print_a_job(jobs);
  return;
}


void print_a_job(job* job) {
  process *proc=job->process_list;
  int index ;

  if(proc->program_name == NULL) {
    printf("\n");
    return;
  }
  printf("%s [%d] ",job->stat==RUNNING ? "Running":"Stopped",job->pgid);
  while( NULL != proc ){
    printf(" %s", proc->program_name);
    
    if(proc->argument_list != NULL) {
      index = 1;
      while(proc->argument_list[index] != NULL) {
        printf( " %s", proc->argument_list[index]);
        index++;
      }
    }
    
    if(proc->input_redirection != NULL) {
      printf(" < %s", proc->input_redirection);
    }
    
    if (proc->output_redirection != NULL)
      printf(" %s %s",
             proc->output_option == TRUNC ? ">" : ">>",
             proc->output_redirection);
    
    printf(" [ %d ]",proc->pid);

    proc = proc->next;
    if( NULL != proc ) printf(" | ");
  }
  printf("\n");
  return;
}


void init(){
  /* setting handler */
  struct sigaction si;
  sigset_t sigset;
  sigemptyset( &sigset );
  si.sa_handler = SIG_IGN;
  si.sa_mask = sigset;
  si.sa_flags = 0;
  sigaction( SIGINT , &si , NULL );

  sigemptyset( &sigset );
  si.sa_handler = SIG_IGN;
  si.sa_mask = sigset;
  si.sa_flags = 0;
  sigaction( SIGTTOU, &si , NULL );

  sigemptyset( &sigset );
  si.sa_handler = SIG_IGN;
  si.sa_mask = sigset;
  si.sa_flags = 0;
  sigaction( SIGTSTP, &si , NULL );

  return ;
}

void init_child(){
  struct sigaction si;
  sigset_t sigset;
  sigemptyset( &sigset );
  si.sa_handler = SIG_DFL;
  si.sa_mask = sigset;
  si.sa_flags = 0;
  sigaction( SIGINT , &si , NULL );

  sigemptyset( &sigset );
  si.sa_handler = SIG_DFL;
  si.sa_mask = sigset;
  si.sa_flags = 0;
  sigaction( SIGTSTP, &si , NULL );
  
  return ;
}

void check_bg(job **bg_job_list){
  job *bg_jobs = *bg_job_list;
  process *proc;
  siginfo_t infop;
  
  if( NULL == *bg_job_list ) return;

  for( proc = bg_jobs->process_list ; proc != NULL ; proc=proc->next){
    infop.si_pid = 0;
    //printf("wait in check_bg [pid:%d]\n",proc->pid);
    if ( -1 == waitid( P_PID , proc->pid , &infop , WEXITED|WSTOPPED|WNOHANG) && ECHILD == errno )continue;
    if( infop.si_pid == 0 || infop.si_code == CLD_STOPPED || infop.si_code == CLD_CONTINUED )
      break;
  }
  if( NULL == proc ){         /* end job */
    *bg_job_list = bg_jobs->next;
    bg_jobs->next= NULL;
    if( infop.si_code == CLD_EXITED ) printf("exited ");
    if( infop.si_code == CLD_KILLED )printf("killed ");
    print_a_job(bg_jobs);
    free(bg_jobs);
  }

  if( NULL == *bg_job_list ) return;

  check_bg( &((*bg_job_list)->next) );
  return ;  
}

void run(job *jobs,job **bg_job_list){
  siginfo_t infop;
  process *proc = jobs->process_list;
  
  tcsetpgrp(STDIN_FILENO,jobs->pgid); /* foreground を渡す */
  jobs->stat=RUNNING;
  killpg(jobs->pgid,SIGCONT);         /* 止まっているかもしれないので */
  
  for( ;  NULL!=proc ;proc=proc->next ){
    //printf("wait in fg [pid:%d]\n",proc->pid);
    waitid( P_PID , proc->pid , &infop , WEXITED|WSTOPPED );
    if( infop.si_code == CLD_STOPPED ){   /* 終了ではなくSIGTSTPによる停止のとき */
      jobs->stat = STOPPED;
      jobs->next = *bg_job_list;
      *bg_job_list = jobs;
      jobs = NULL;
      break;                    /* スタックに積む */
    }
  }
  
  free_job(jobs);
  tcsetpgrp(STDIN_FILENO,getpgid(0)); /* forgroundを取り返す */  
  return;
}

void bg( job *bg_job_list , int pgid ){
  if( NULL == bg_job_list ){
    printf("bg: No background job\n");
    return ;
  }
  if( 0 == pgid ){
    bg_job_list->stat =RUNNING;
    killpg( bg_job_list->pgid , SIGCONT );
    return;
  }

  job *jobs;
  for( jobs = bg_job_list ; NULL != jobs ; jobs = jobs->next ){
    if( pgid == jobs->pgid ){
      jobs->stat = RUNNING;
      killpg(jobs->pgid,SIGCONT);
      return;
    }
  }
  printf("bg: Invalid pgid [%d]\n",pgid);
  return;
}


void fg(job** bg_job_list,int pgid){
  job *bg_jobs = *bg_job_list;
  
  if( NULL == *bg_job_list ){
    printf("fg: Invalid pgid [%d]\n",pgid);
    return;
  }
  if( 0 == pgid || pgid == bg_jobs->pgid){
    *bg_job_list = bg_jobs->next;
    bg_jobs->next = NULL;
    run(bg_jobs , bg_job_list);
  }else{
    fg( &((*bg_job_list)->next) , pgid);
  }
  return;
}
