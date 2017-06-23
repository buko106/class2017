#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>

uint32_t fadd(uint32_t,uint32_t);

unsigned long long E(unsigned long long x){
  return (x&0x7f800000)>>23;
}

unsigned long long F(unsigned long long x){
  return x&0x007fffff;
} 

int is_NaN(uint32_t x){
  return E(x)==0xff && F(x)!=0;
}

int is_Sub(uint32_t x){
  return E(x)==0 && F(x)!=0; 
}

void show_binary(uint32_t b,char buf[]){
  int i;
  for(i=0;i<32;++i){
    putc((int)'0' + ((b>>(31-i)) & 1),stdout );
    if(31==31-i || 23==31-i)
      putc(' ',stdout);
  }
  printf(":%s\n",buf);
}

int main(){
  union{
    uint32_t i;
    float f;
    char c[4];
  } a,b,ans,plus;
  int i,count=0;
  //scanf("%f %f",&a.f,&b.f);
  init_genrand(time(NULL));
  while(1){
    for(i=0;i<4;++i){
      a.c[i]=genrand_int32()&0xff;
      b.c[i]=genrand_int32()&0xff;
    }
    if(is_NaN(a.i) || is_NaN(b.i)
       ||(a.i>>23)==0x000||(a.i>>23)==0x100||(b.i>>23)==0x000||(b.i>>23)==0x100)continue;

    ans.i = fadd(a.i,b.i);
    plus.f = a.f + b.f;
    if(ans.f!=plus.f && !is_Sub(plus.i)) {
      printf("a=0x%0x, b=0x%0x\n",a.i,b.i);
      show_binary(a.i,"a");
      show_binary(b.i,"b");
      printf("fadd -> 0x%08x = %f\n",ans.i,ans.f);
      printf("  +  -> 0x%08x = %f\n",plus.i,plus.f);
      show_binary(plus.i,"plus");
      printf("diff = %f\n",plus.f-ans.f);
      return -1;
    }
    ++count;
    if(count%100000000==0)printf("count=%d\n",count);
  }
  return 0;
}
