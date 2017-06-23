#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <unistd.h>
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
  char buf[BUF_SIZE],return_buf[BUF_SIZE];
  if(argc!=3){
    printf("Usage:udpechoclient (host) (port number)\n");
    exit(-1);
  }

  port = atoi(argv[2]);
  addr.sin_family = AF_INET;
  addr.sin_port = htons(port);
  inet_pton(AF_INET,argv[1],&addr.sin_addr);

  if(0>(sfd = socket(AF_INET,SOCK_STREAM,IPPROTO_TCP)))
    perror_exit("socket");
  if(-1==connect(sfd,(struct sockaddr*)&addr,addrlen))
    perror_exit("connect");
  printf("connect-complete\n");
  while(EOF!=scanf("%s",buf)){
    if(-1==(count=write(sfd,buf,BUF_SIZE)))
      perror_exit("write");
    //printf("write-complete\n");
    if(count>0)
      if(-1==read(sfd,return_buf,count))
        perror_exit("read");
    //printf("read-complete\n");
    printf("%s\n",return_buf);
  }
  close(sfd);
  return 0;
}
