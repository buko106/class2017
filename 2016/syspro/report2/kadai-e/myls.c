#include <stdio.h>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <pwd.h>
#include <grp.h>


void mode_to_str(char buf[11],int mode){
  buf[0]= S_IFDIR&mode?'d':'-';
  buf[1]= S_IRUSR&mode?'r':'-';
  buf[2]= S_IWUSR&mode?'w':'-';
  buf[3]= S_IXUSR&mode?'x':'-';
  buf[4]= S_IRGRP&mode?'r':'-';
  buf[5]= S_IWGRP&mode?'w':'-';
  buf[6]= S_IXGRP&mode?'x':'-';
  buf[7]= S_IROTH&mode?'r':'-';
  buf[8]= S_IWOTH&mode?'w':'-';
  buf[9]= S_IXOTH&mode?'x':'-';
  buf[10]='\0';
  return;
}

int main(int argc,char *argv[]){
  DIR *dir;
  struct dirent *dp;
  struct stat s;
  struct tm *t;
  struct passwd *pw;
  struct group *gr;
  char buf[11];

  dir=opendir(".");
  for(dp = readdir(dir);dp!=NULL;dp=readdir(dir)){
    if(strcmp(dp->d_name,".")==0||strcmp(dp->d_name,"..")==0)continue;
    stat(dp->d_name,&s);
    mode_to_str(buf,s.st_mode);
    t = localtime(&s.st_atime);
    pw = getpwuid(s.st_uid);
    gr = getgrgid(s.st_gid);
    printf("%s %1d %s %s %6d %2d月 %2d %02d:%02d %s\n",buf,(int)s.st_nlink,pw->pw_name,gr->gr_name,(int)s.st_size,1+t->tm_mon,t->tm_mday,t->tm_hour,t->tm_min,dp->d_name);
  }
  return 0;
}
