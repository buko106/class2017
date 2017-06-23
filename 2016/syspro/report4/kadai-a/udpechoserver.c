#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <signal.h>

#define perror_exit(msg) do{perror(msg); exit(-1);}while(0)
#define BUF_SIZE 1024

void SigHandler(int signum){
  printf("終了します\n");
  exit(0);
}

int main(int argc,char *argv[]){
  int port;
  int sfd,fsfd;
  int count;
  struct sockaddr_in addr,from;
  socklen_t addrlen=sizeof(struct sockaddr_in);
  char buf[BUF_SIZE];
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
  if(0>(sfd = socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP)))
    perror_exit("socket");
  if(-1==bind(sfd,(struct sockaddr*) &addr,sizeof(addr)))
    perror_exit("bind");

  while(1){
    if(-1==recvfrom(sfd,buf,sizeof(buf),0,(struct sockaddr*) &from,&addrlen))
       perror_exit("recvfrom");
    /* printf("recvfrom-complete\n"); */
    sendto(sfd,buf,sizeof(buf),0,(struct sockaddr*)&from,addrlen);
    /* printf("sendto-complete\n"); */
  }
  close(sfd);
  return 0;
}
