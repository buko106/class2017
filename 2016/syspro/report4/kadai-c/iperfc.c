#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <string.h>
#include <sys/time.h>

#define perror_exit(msg) do{perror(msg); exit(-1);}while(0)
#define BUF_SIZE 1024
#define NUM_WRITE (1024*1024)

int main(int argc,char *argv[]){
  int i;
  int port;
  int sfd;
  int data_size;
  struct sockaddr_in addr;
  socklen_t addrlen=sizeof(struct sockaddr_in);
  char buf[BUF_SIZE];
  struct timeval t1,t2;
  double t;
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
  //printf("connect-complete\n");
  gettimeofday(&t1,NULL);
  for(i=0;i<NUM_WRITE;++i){
    if(-1==write(sfd,buf,BUF_SIZE))
      perror_exit("write");
    //printf("write-complete\n")
  }
  read(sfd,&data_size,sizeof(data_size));
  gettimeofday(&t2,NULL);
  t =(double)(t2.tv_sec-t1.tv_sec)
    +(double)(t2.tv_usec-t1.tv_usec)/1000.0/1000.0;
  printf("%d %lf %lf\n",data_size,t,8.0*data_size/1024.0/1024.0/t);
  close(sfd);
  return 0;
}
