#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <netdb.h>
#include <signal.h>
#include <pthread.h>

#define perror_exit(msg) do{perror(msg); exit(-1);}while(0)
#define BUF_SIZE 1024
#define QUEUE_SIZE 5
#define MAX_CONNECTION 1024

void SigHandler(int signum){
  printf("終了します\n");
  exit(0);
}


void *echo(void *p){
  int client_sfd=*(int*)p;
  int count;
  char buf[BUF_SIZE];
  pthread_detach(pthread_self());
  while(1){
    if(-1==(count=read(client_sfd,buf,BUF_SIZE)))
      perror_exit("read");
    //printf("read-complete\n");
    if(count==0)break;
    if(count>0)
      if(-1==write(client_sfd,buf,count))
        perror_exit("write");
    //printf("write-complete\n");
  }
  close(client_sfd);
  *(int*)p = -1;
  return NULL;
}


int main(int argc,char *argv[]){
  int port;
  int sfd,client_sfd[MAX_CONNECTION];
  int i;
  struct sockaddr_in addr,client_addr;
  socklen_t addrlen=sizeof(struct sockaddr_in);
  pthread_t pthread[MAX_CONNECTION];
  if(argc!=2){
    printf("Usage:udpechoserver (port number)\n");
    exit(-1);
  }
  
  port = atoi(argv[1]);
  addr.sin_family = AF_INET;
  addr.sin_port = htons(port);
  addr.sin_addr.s_addr = INADDR_ANY;
  
  if(SIG_ERR==signal(SIGINT,SigHandler))
    perror_exit("signal");
  if(0>(sfd = socket(AF_INET,SOCK_STREAM,IPPROTO_TCP)))
    perror_exit("socket");
  if(-1==bind(sfd,(struct sockaddr*) &addr,sizeof(addr)))
    perror_exit("bind");
  if(-1==listen(sfd,QUEUE_SIZE))
    perror_exit("listen");
  //printf("listen-complete\n");

  for(i=0;i<MAX_CONNECTION;i++){
    client_sfd[i]=-1;
  }
  
  while(1){
    for(i=0;i<MAX_CONNECTION;i++){
      if(-1==client_sfd[i]){
        if(-1==(client_sfd[i]=accept(sfd,(struct sockaddr*) &client_addr,&addrlen)))
          perror_exit("accept");
        //printf("accept-complete\ncall pthread[%d]\n",i);
        pthread_create(&pthread[i],NULL,echo,(void*)&client_sfd[i]);
        break;
      }
    }
    if(i==MAX_CONNECTION){
      printf("Too many clients\n");
      break;
    }
  }
  close(sfd);
  return 0;
}
