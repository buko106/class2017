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
  char buf[BUF_SIZE];
  struct sockaddr_in addr;
  fd_set client_fds;
  fd_set client_fds_read;
  
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


  FD_ZERO(&client_fds);
  FD_SET(sfd,&client_fds);
  while(1){
    struct timeval wait_time;
    wait_time.tv_sec = 5;
    wait_time.tv_usec= 0;
    memcpy(&client_fds_read ,&client_fds,sizeof(client_fds));
    if(-1==select(FD_SETSIZE,&client_fds_read,NULL,NULL,&wait_time))
      perror_exit("select");

    for(i=0;i<FD_SETSIZE;++i){
      if( FD_ISSET(i,&client_fds_read) ){
        if(i == sfd){           /* new client has come */
          int new_client = accept_new_client(sfd);
          if(-1==new_client)
            perror_exit("accept");
          if(new_client <= FD_SETSIZE-1){
            FD_SET(new_client,&client_fds);
            //printf("accept-complete\n");
          }else{
            close(new_client);
          }
        }else{                  /* ready to read */
          count = read(i,buf,BUF_SIZE);
          if(-1==count || 0==count){    /* client disconnected */
            close(i);
            FD_CLR(i,&client_fds);
            //printf("client-disconnected\n"); 
          }
          // else printf("read-complete\n");
          if(-1==write(i,buf,count)){
            close(i);
            FD_CLR(i,&client_fds);
            printf("client-disconnected\n");
          }//else printf("write-complete\n");
        }
      }
    }
  }
  close(sfd);
  return 0;
}
