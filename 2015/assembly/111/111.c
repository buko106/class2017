#include<stdio.h>

extern double make_double(int,int,long long);
int main(){
  int s,e;
  long long f;
  scanf("%d %d %lld",&s,&e,&f);
  if(0<=s&&s<(1<<1) && 0<=e&&e<(1<<11) && 0<=f&&f<((long long)1 <<52))
    printf("%.15lf\n",make_double(s,e,f));
  else
    printf("sign is less than %lld\nexponent is less than %lld\nfraction is less then %lld\\
n",(long long)1<<1,(long long)1<<11,((long long) 1)<<52);
  return 0;
}

//0 0 0
//1 0 0
//1 1023 0
//0 2047 0
//0 2047 1
//1 2047 0
//0 1023 900719925474099
