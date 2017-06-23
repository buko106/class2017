#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <fcntl.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>

#define MAX_COUNT 1

int main(int argc,char *argv[]){
  FILE *fp_source,*fp_dest;  /* ファイル構造体へのポインタを定義*/
  int ret,count;
  char buf[MAX_COUNT];

  /* 時間計測用 */
  struct timeval s,t;

  if(argc!=3){
    printf("USAGE>./mycp SOURCE DEST\n");
    return 0;
  } /* 入力が不正ならエラー */

  fp_source = fopen(argv[1],"r");
  if(fp_source==NULL){
    perror(argv[1]);
    return 0;
  }
  fp_dest   = fopen(argv[2],"w");
  if(fp_source==NULL){
    perror(argv[2]);
    return 0;
  }

  gettimeofday(&s,NULL);

  while(1){
    count = fread(buf,sizeof(char),MAX_COUNT,fp_source);
    if(count<MAX_COUNT&&ferror(fp_source)){        /* fread内でエラー or EOF */
      perror(NULL);
      return 0;
    }else{
      ret = fwrite(buf,sizeof(char),count,fp_dest);
      if(ret<count&&ferror(fp_dest)){ /* fwrite内でエラー */
        perror(NULL);
        return 0;   
      }
    }
    if(feof(fp_source)) break;  /* EOF->break */
  }
  
  gettimeofday(&t,NULL);
  printf("%d.%06ds\n",(int)t.tv_sec-(int)s.tv_sec,(int)t.tv_usec-(int)s.tv_usec);

  fclose(fp_source);
  fclose(fp_dest);
  return 0;
}
