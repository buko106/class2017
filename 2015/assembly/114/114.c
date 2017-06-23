#include<stdio.h>


extern int ack(int,int);
int a(int m,int n){
  if(m==0)return n+1;
  if(n==0)return a(m-1,1);
  return a(m-1,a(m,n-1));
}

int main(){
  int m,n,flag;
  scanf("%d %d %d",&m,&n,&flag);
  if(flag)printf("%d\n",ack(m,n));
  else printf("%d\n",a(m,n));
  return 0;
}
