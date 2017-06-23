#include<stdio.h>

extern int fact(int i);
int main(){
  int i,n;
  scanf("%d",&n);
  for(i=0;i<=n;i++){
    printf("%d\n",fact(i));
  }
  return 0;
}
