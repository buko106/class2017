#include<stdio.h>

typedef unsigned long long DWORD;
extern DWORD* mul128(DWORD*,DWORD*,DWORD*);
int main(){
  DWORD a[2],b[2],c[2];
  scanf("%llx %llx",&a[0],&a[1]);
  scanf("%llx %llx",&b[0],&b[1]);
  mul128(a,b,c);
  printf("%016llx %016llx\n",c[0],c[1]);
  return 0;
}
