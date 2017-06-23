#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <fcntl.h>
#include <unistd.h>
#include <netdb.h>
#include <signal.h>
#include <pthread.h>

#define perror_exit(msg) do{perror(msg); exit(-1);}while(0)
#define BUF_SIZE 1024
#define QUEUE_SIZE 10
#define MAX_CONNECTION 1024

char *root;
int sfd;

void SigHandler(int signum){
  printf("終了します\n");
  close(sfd);
  exit(0);
}

void send_msg(int sfd,char *msg){
  int len=strlen(msg);
  if(len != write(sfd,msg,len)){
    perror("send_msg");
  }
  return;
}

void *http(void *p){
  int client_sfd=*(int*)p,fd,len;
  char buf[BUF_SIZE];
  char method[BUF_SIZE],request[BUF_SIZE],http_version[BUF_SIZE];
  char header[BUF_SIZE];
  pthread_detach(pthread_self());
  if(-1==read(client_sfd,buf,BUF_SIZE)){
    perror("read Method etc.");
  }else{
    //printf("recieve request\n");
    
    if(3 != sscanf(buf,"%s %s %s",method,request,http_version)){
                                /*  Bad Request */
      send_msg(client_sfd,"HTTP/1.1 400 Bad Request\r\n");
      send_msg(client_sfd,"Connection: close\r\n");
    }else if( 0 != strcmp("HTTP/1.1",http_version) ){
                                /* HTTP Version not supported */
      send_msg(client_sfd,"HTTP/1.1 505 HTTP Version not supported\r\n");
      send_msg(client_sfd,"Connection: close\r\n");
    }else if((0 != strcmp("GET",method) && 0 != strcmp("HEAD",method))){
                                /* Not Implemented */
      send_msg(client_sfd,"HTTP/1.1 501 Not Implemented\r\n");
      send_msg(client_sfd,"Connection: close\r\n");
    }else{                      /* OK */
      while( 0 < read(client_sfd,buf,BUF_SIZE) ){/* 全体をパース */
        if( buf[0]=='\r' && buf[1]=='\n') break; /* "\r\n"がおくられて来た */
        sscanf(buf,"%s",header);
        /* 
           if( 0 == strcmp(" ...." , header){
              ... ここで必要ならば処理をする
           }
         */
      }  
      char *document = calloc(strlen(root)+strlen(request),sizeof(char));
      if(NULL == document){
        perror("calloc");
        send_msg(client_sfd,"HTTP/1.1 500 Internal Server Error\r\n");
        send_msg(client_sfd,"Connection: close\r\n");
      }else{
        strcpy(document,root);
        strcat(document,&request[1]);
        if( NULL!=strstr(document,"..") ){               /* 相対参照を用いていないか */
          send_msg(client_sfd,"HTTP/1.1 403 Forbidden\r\n");
          send_msg(client_sfd,"Connection: close\r\n");
        }else if( -1 == (fd = open(document,O_RDONLY))){
          perror("open");
          send_msg(client_sfd,"HTTP/1.1 404 Not found\r\n");
          send_msg(client_sfd,"Connetction: close\r\n");
        }else{
          send_msg(client_sfd,"HTTP/1.1 200 OK\r\n");
          send_msg(client_sfd,"Connetction: close\r\n");
          if(0 == strcmp("GET",method)){
            while(0 < (len = read(fd,buf,BUF_SIZE))){
              write(client_sfd,buf,len);
            }
          }
        }
      }
      send_msg(client_sfd,"\r\n");
      free(document);
    }
  }
  close(fd);
  close(client_sfd);
  *(int*)p = -1;
  return NULL;
}


int main(int argc,char *argv[]){
  int port;
  int client_sfd[MAX_CONNECTION];
  int i;
  struct sockaddr_in addr,client_addr;
  socklen_t addrlen=sizeof(struct sockaddr_in);
  pthread_t pthread[MAX_CONNECTION];
  if(argc!=3){
    printf("Usage:httpserver [port] [document root]\n");
    exit(-1);
  }

  root = argv[2];               /* 大域にドキュメントルートがわかるように */
  printf("documet root=%s\n",root);
  port = atoi(argv[1]);
  addr.sin_family = AF_INET;
  addr.sin_port = htons(port);
  addr.sin_addr.s_addr = INADDR_ANY;
  
  if(SIG_ERR==signal(SIGTERM,SigHandler)||SIG_ERR==signal( SIGPIPE , SIG_IGN ))
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
        pthread_create(&pthread[i],NULL,http,(void*)&client_sfd[i]);
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
