#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <netdb.h>
#include <signal.h>



#define perror_exit(msg) do{perror(msg); exit(-1);}while(0)
#define BUF_SIZE 1024
#define NUM_READ (1024*1024)
#define QUEUE_SIZE 5

void SigHandler(int signum){
  printf("終了します\n");
  exit(0);
}

int accept_new_client(int sfd){
  struct sockaddr_in client_addr;
  socklen_t addrlen = sizeof(struct sockaddr_in);
  int client_sfd = accept(sfd,(struct sockaddr*) &client_addr,&addrlen);
  if (-1==client_sfd)
    return -1;
  return client_sfd;
}


int main(int argc,char *argv[]){
  int port;
  int sfd;
  int i;
  int count;
  int data_size=0;
  char buf[BUF_SIZE];
  struct sockaddr_in addr,client_addr;
  socklen_t addrlen=sizeof(struct sockaddr_in);
  int client_sfd;

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
  client_sfd = accept(sfd,(struct sockaddr*) &client_addr,&addrlen);
  if (-1==client_sfd)
    perror_exit("accept");
  //printf("accept-complete\n");
  for(i=0;i<NUM_READ;++i){
    if(-1==(count=read(client_sfd,buf,BUF_SIZE)))
      perror_exit("read");
    //printf("%d ",count);
    data_size+=count;;
  }
  write(client_sfd,&data_size,sizeof(data_size));
  //printf("receive %d bytes\n",data_size);
  close(sfd);
  return 0;
}
