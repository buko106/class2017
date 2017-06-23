#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <fcntl.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>

#define MAX_COUNT 1

int main(int argc,char *argv[]){
  int fd_source,fd_dest,count,written,ret;
  char buf[MAX_COUNT];
  struct stat st;

  /* 時間計測用 */
  struct timeval s,t;

  if(argc!=3){
    printf("USAGE>./mycp SOURCE DEST\n");
    return 0;
  } /* 入力が不正ならエラー */

  fd_source = open(argv[1],O_RDONLY);
  if(fd_source==-1){
    perror(argv[1]);
    return 0;
  } /* 入力ファイルが読めなかったらエラー */
  
  fstat(fd_source,&st); /* sourceのstatを取得 */
  
  fd_dest = open(argv[2],O_WRONLY|O_CREAT,st.st_mode);
  if(fd_dest==-1){
    perror(argv[2]);
    return 0;
  } /* 出力ファイルが開けなかったらエラー */

  gettimeofday(&s,NULL);

  while(1){
    count = read(fd_source,buf,MAX_COUNT);
    written = 0;
    if(count==-1){              /* read内でエラー */
      perror(NULL);
      return 0; 
    }else if(count==0){
      break;
    }else{
      while(written<count){
        ret = write(fd_dest,buf+written,count-written);
        written += ret;
        if(ret==-1){            /* write内でエラー */
          perror(NULL);
          return 0;
        }
      }
    }
  }
  
  gettimeofday(&t,NULL);
  printf("%d.%06ds\n",(int)t.tv_sec-(int)s.tv_sec,(int)t.tv_usec-(int)s.tv_usec);

  close(fd_source);
  close(fd_dest);
  return 0;
}
