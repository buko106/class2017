#include<stdio.h>


extern int fib(int i);
int fib_c(int i){
  if(i<2)return i;
  return fib(i-1)+fib(i-2);
}
int main(){
  int i,n,flag;
  scanf("%d %d",&n,&flag);
  for(i=0;i<=n;i++){
    if(flag)
      printf("%d\n",fib(i));
    else
      printf("%d\n",fib_c(i));
  }
  return 0;
}
