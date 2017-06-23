#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>

static void handler(int sig) {
  printf("\r[%s:%d] Signal: %d\n", __FILE__, __LINE__, sig);
}

#define SIZE 4096
int main(int argc, char **argv) {
  int i;
  pid_t child_pid, pid;
  struct sigaction sa;
  char buf[SIZE],*p;

  sigemptyset(&sa.sa_mask);
  sa.sa_flags = SA_RESTART;

  sa.sa_handler = handler;
  sigaction(SIGINT, &sa, NULL);
  sigaction(SIGTSTP, &sa, NULL);
  sigaction(SIGQUIT, &sa, NULL);

  if ((child_pid = fork()) > 0) {
    setpgid(child_pid, 0);
    tcsetpgrp(0, child_pid);
    kill(child_pid, SIGCONT);

    for (i=0; i<600*1000; i++) {
      pid = waitpid(child_pid, NULL, WNOHANG);

      if (pid<0) exit(1);
      if (pid>0) { puts("OK"); exit(0); }

      usleep(1000);
    }
    kill(pid, SIGKILL);
  } else {

    while (1) {
      p = fgets(buf, SIZE, stdin);
      printf("%s", (p!=NULL) ? buf : "EOF\n");
    }
  }

  exit(1);
}
