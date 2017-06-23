#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <fcntl.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <ctype.h>

#define MAX_COUNT 512

int main(int argc,char *argv[]){
  int fd,count,i,l,w,b,tmp,prev;
  char buf[MAX_COUNT];

  if(argc!=2){
    printf("USAGE>./mywc FILE\n");
    return 0;
  } /* 入力が不正ならエラー */

  fd = open(argv[1],O_RDONLY);
  if(fd==-1){
    perror(argv[1]);
    return 0;
  } /* 入力ファイルが読めなかったらエラー */
  

  l = 0;w = 0;b = 0;
  prev = isspace(' ');
  while(1){
    count = read(fd,buf,MAX_COUNT);
    if(count==-1){              /* read内でエラー */
      perror("read error");
      return 0; 
    }else if(count==0){
      break;
    }else{
      b+=count;
      for(i=0;i<count;++i){
        tmp=isspace(buf[i]);
        if('\n'==buf[i])++l;
        if(prev && !tmp)++w;
        prev=tmp;
      }
    }
  }
  
  printf("%7d%7d%7d\n",l,w,b);
  close(fd);
  return 0;
}
