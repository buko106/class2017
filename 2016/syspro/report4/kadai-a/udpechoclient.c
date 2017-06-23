#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <string.h>

#define perror_exit(msg) do{perror(msg); exit(-1);}while(0)
#define BUF_SIZE 1024

int main(int argc,char *argv[]){
  int port;
  int sfd;
  int count;
  struct sockaddr_in addr;
  socklen_t addrlen=sizeof(struct sockaddr_in);
  char buf[BUF_SIZE];
  if(argc!=3){
    printf("Usage:udpechoclient (host) (port number)\n");
    exit(-1);
  }

  port = atoi(argv[2]);
  addr.sin_family = AF_INET;
  addr.sin_port = htons(port);
  inet_pton(AF_INET,argv[1],&addr.sin_addr);

  if(0>(sfd = socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP)))
    perror_exit("socket");
  while(EOF!=scanf("%s",buf)){
    sendto(sfd,buf,sizeof(buf),0,(struct sockaddr*)&addr,addrlen);
    /* printf("sendto-complete\n"); */
    if(-1==recvfrom(sfd,buf,sizeof(buf),0,NULL,NULL))
      perror_exit("recvfrom");
    /* printf("recvfrom-complete\n"); */
    printf("%s\n",buf);
  }
  return 0;
}
