#include<signal.h>
#include<unistd.h>

volatile int count=0;

void handler(int);

int main(){
  struct sigaction si;
  sigset_t sigset;
  sigemptyset( &sigset );
  
  si.sa_handler = handler;
  si.sa_mask = sigset;
  si.sa_flags = 0;
  sigaction( SIGINT , &si , NULL );
  while(1){
    
  }
  return 0;
}


void handler(int signal){
  if( SIGINT == signal ){
    ++ count ;
    if( count >= 10 ){
      if( 5 > write(STDOUT_FILENO,"exit\n",5) )
        _exit(1);
      else
        _exit(0);
    }
  }
  return;
}
