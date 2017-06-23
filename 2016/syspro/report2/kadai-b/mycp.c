#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>

#define MAX_COUNT 512

int main(int argc,char *argv[]){
  int fd_source,fd_dest,count,written,ret;
  char buf[MAX_COUNT];
  struct stat st;
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

  fd_dest = open(argv[2],O_WRONLY|O_CREAT,O_WRONLY);
  if(fd_dest==-1){
    perror(argv[2]);
    return 0;
  } /* 出力ファイルが開けなかったらエラー */

  while(1){
    count = read(fd_source,buf,MAX_COUNT);
    written = 0;
    if(count==-1){              /* read内でエラー */
      perror("read");
      return 0; 
    }else if(count==0){
      break;
    }else{
      while(written<count){
        ret = write(fd_dest,buf+written,count-written);
        written += ret;
        if(ret==-1){            /* write内でエラー */
          perror("write");
          return 0;
        }
      }
    }
  }
  

  fchmod(fd_dest,st.st_mode);   /* fchmodでパーミッションを上書き */
  close(fd_source);
  close(fd_dest);
  return 0;
}
