#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <sys/time.h>
#include <fcntl.h>


int main(){
  int i,n;
  pid_t pid;
  struct timeval s,t;
  scanf("%d",&n);
  gettimeofday(&s,NULL);
  for(i=0;i<n;++i){
    pid = syscall(SYS_getpid);
  }
  gettimeofday(&t,NULL);
  printf("%d-%d=%dus\n",(int)t.tv_usec,(int)s.tv_usec,(int)t.tv_usec-(int)s.tv_usec);
  return 0;
}
