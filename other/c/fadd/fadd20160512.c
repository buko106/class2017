#include <stdio.h>
#include <stdint.h>

void show_binary(unsigned long long b,char buf[]){
  int i;
  for(i=0;i<32;++i){
    printf("%u",((unsigned)b>>(31-i))&1);
    if(i==0||i==8)printf(" ");
  }
  printf(":%s\n",buf);
}

uint32_t fadd(uint32_t a,uint32_t b){
  unsigned long long sign_a,sign_b;
  unsigned long long exp_a,exp_b;
  unsigned long long frac_a,frac_b;
  unsigned long long winer,loser,shift,sum,exp,R,G,ulp,i;
  
  uint32_t NaN = 0x7fc00000;    /* 0 11111111 110000... */
  uint32_t NNaN= 0xffc00000;    /* 1 11111111 110000... */
  uint32_t Inf = 0x7f800000;    /* 0 11111111 000000... */
  uint32_t NInf= 0xff800000;    /* 1 11111111 000000... */
  uint32_t Zero= 0x00000000;    /* 0 00000000 000000... */
  uint32_t NZero=0x80000000;    /* 1 00000000 000000... */
  sign_a = a >> 31;             /* a[31:31] */
  sign_b = b >> 31;             /* b[31:31] */
  exp_a = (a>>23)&((1<<8)-1);   /* a[30:23] */
  exp_b = (b>>23)&((1<<8)-1);   /* b[30:23] */
  frac_a = a & ((1<<23)-1);     /* a[22:0] */
  frac_b = b & ((1<<23)-1);     /* b[22:0] */
  /* printf("a:sign = %llu, exp = %llu, frac = %llu\n",sign_a,exp_a,frac_a); */
  /* printf("b:sign = %llu, exp = %llu, frac = %llu\n",sign_b,exp_b,frac_b); */
  /* printf("a = %08x,b = %08x\n",a,b); */
   /* show_binary(a,"a");show_binary(b,"b"); */

  int is_NaN_a  = exp_a==0xff && frac_a!=0;
  int is_NaN_b  = exp_b==0xff && frac_b!=0;
  int is_Inf_a  = sign_a==0 && exp_a==0xff && frac_a==0;
  int is_Ninf_a = sign_a==1 && exp_a==0xff && frac_a==0;
  int is_Inf_b  = sign_b==0 && exp_b==0xff && frac_b==0;
  int is_Ninf_b = sign_b==1 && exp_b==0xff && frac_b==0;
  int is_Zero_a = sign_a==0 && exp_a==0 && frac_a==0;
  int is_Zero_b = sign_b==0 && exp_b==0 && frac_b==0;
  int is_NZero_a= sign_a==1 && exp_a==0 && frac_a==0;
  int is_NZero_b= sign_b==1 && exp_b==0 && frac_b==0;
  if(is_NaN_a||is_NaN_b)  return NaN;  /* NaN + _ = NaN */
  if(is_Inf_a&&is_Inf_b)  return Inf;  /* inf + inf = inf */
  if(is_Inf_a&&is_Ninf_b) return NNaN; /* in  + -inf = -NaN */
  if(is_Ninf_a&&is_Inf_b) return NNaN; /* -inf+ inf = -NaN */
  if(is_Ninf_a&&is_Ninf_b)return NInf; /* -inf+ -inf = -inf */
  if(is_Inf_a || is_Inf_b)return Inf;  /* inf + _ = inf */
  if(is_Ninf_a||is_Ninf_b)return NInf; /* -int + _ = -inf */
  if(is_NZero_a&&is_NZero_b)return NZero; /* -0 + -0 = -0 */
  if(is_Zero_a||is_NZero_a) return b;
  if(is_Zero_b||is_NZero_b) return a;

  if(sign_a==sign_b){
    if(exp_a>exp_b){winer=(1<<24)|(frac_a<<1);loser=(1<<24)|(frac_b<<1);shift=exp_a-exp_b;exp=exp_a;}
    else           {winer=(1<<24)|(frac_b<<1);loser=(1<<24)|(frac_a<<1);shift=exp_b-exp_a;exp=exp_b;}
    
    R=0;
    for(i=0;i<shift;++i){       /* for だとやばい */
      R |= 1 & loser;
      loser >>= 1;
    }
    /* show_binary(winer,"winer"); */
    /* show_binary(loser,"loser"); */
    sum = winer + loser ;           
                              /* show_binary(sum,"sum");   show_binary(sum,"sum 2"); */
    if( (1<<25) & sum ) {exp += 1;R|= 1 & sum ;sum>>=1;} /* 桁上がり */
    G = 1 & sum ;
    ulp = 1 & (sum>>1);
    if(G&&(ulp || R)) sum += 2;    /* round up */
    if(exp==0xff) sum=0;
    else if ((1<<25)& sum ) {exp += 1;sum>>=1;} /* 1.1111111111から桁上がりした */
    uint32_t ret = (sign_a<<31) | (exp<<23) | (((1<<23)-1) & (sum>>1));
    /* show_binary(ret,"ret"); */
    return ret;
  }
  
  return Zero;
}
