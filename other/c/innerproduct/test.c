#include <stdio.h>

int main(){
  long double a , b ;
  
  scanf("%Lf %Lf",&a,&b);
  a = a * b ;
  b = a * b ;
  printf("%lu %Le %Le\n",sizeof(long double),a,b);
  return 0;
}
