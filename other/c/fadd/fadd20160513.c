#include <stdio.h>
#include <stdint.h>

static enum fadd_enum{
  OFFSET_SIGN = 31,
  OFFSET_EXP  = 23,
  MASK_SIGN = 1ull<<OFFSET_SIGN,
  MASK_EXP  = ((1ull<<OFFSET_SIGN)-1) - ((1ull<<OFFSET_EXP)-1),
  MASK_FRAC = (1ull<<OFFSET_EXP)-1,
};

static void show_binary(unsigned long long,char*);
static unsigned long long mask(unsigned long long,unsigned long long);
static unsigned long long bit(unsigned long long);
static unsigned long long S(unsigned long long);
static unsigned long long E(unsigned long long);
static unsigned long long F(unsigned long long);
static int is_NaN(uint32_t);

uint32_t fadd(const uint32_t a,const uint32_t b){
  uint32_t NaN = 0x7fc00000;    /* 0 11111111 110000... */
  uint32_t NNaN= 0xffc00000;    /* 1 11111111 110000... */
  uint32_t Inf = 0x7f800000;    /* 0 11111111 000000... */
  uint32_t NInf= 0xff800000;    /* 1 11111111 000000... */
  uint32_t Zero= 0x00000000;    /* 0 00000000 000000... */
  uint32_t NZero=0x80000000;    /* 1 00000000 000000... */
  if(is_NaN(a)||is_NaN(b)) return NaN; /* NaN + _ = NaN */
  if(a==Inf  && b==Inf) return Inf; /* inf + inf = inf */
  if(a==Inf  && b==NInf) return NNaN;
  if(a==NInf && b==Inf) return NNaN;
  if(a==NInf && b==NInf) return NInf;
  if(a==Inf  || b==Inf) return Inf;
  if(a==NInf || b==NInf) return NInf;
  if(a==NZero&& b==NZero)return NZero;
  if(a==Zero || a==NZero)return b;
  if(b==Zero || b==NZero)return a;

  unsigned long long winer,loser,shift,sum,sign,exp,R,G,ulp,i;
  
  if(S(a)==S(b)){               /* 同符号->add */
    if(E(a)>E(b)){              /* aが絶対値大きい */
      winer = bit(2+OFFSET_EXP) | (F(a)<<2);
      loser = bit(2+OFFSET_EXP) | (F(b)<<2);
      shift = E(a)-E(b);
      sign = S(a);
      exp = E(a);
    }else{
      winer = bit(2+OFFSET_EXP) | (F(b)<<2);
      loser = bit(2+OFFSET_EXP) | (F(a)<<2);
      shift = E(b)-E(a);
      sign = S(b);
      exp = E(b);
    }

    for(i=0;i<shift;++i){         /* forだとやばい */
      loser = (loser>>1) | (loser&bit(0));
    }
    sum = winer+loser;
    if(sum&bit(3+OFFSET_EXP)){    /* 繰り上がりで１桁増えた */
      exp += 1;
      sum = (sum>>1) | (sum&bit(0));
    }
    R   = sum&bit(0);
    G   = sum&bit(1);
    ulp = sum&bit(2);
    if(G&&(ulp||R)) sum += bit(2);     /* round to even */
  
    if(exp==0xff) sum=0;          /* inf */
    else if(sum&bit(3+OFFSET_EXP)){ /* 1.11111111111111から桁上がりした */
      exp += 1;
      sum = sum >> 1;
    }
    return (sign<<OFFSET_SIGN) | (exp<<OFFSET_EXP) | ((sum>>2)&MASK_FRAC);
  }else{                        /* 異符号->sub */
    if((a&(MASK_EXP|MASK_FRAC))==(b&(MASK_EXP|MASK_FRAC))){
      return Zero;/* 正負で同じ大きさ */
    }else if((a&(MASK_EXP|MASK_FRAC))>(b&(MASK_EXP|MASK_FRAC))){
      /* aが絶対値大きい */
      winer = bit(3+OFFSET_EXP) | (F(a)<<3);
      loser = bit(3+OFFSET_EXP) | (F(b)<<3);
      shift = E(a)-E(b);
      sign = S(a);
      exp  = E(a);
    }else{
      winer = bit(3+OFFSET_EXP) | (F(b)<<3);
      loser = bit(3+OFFSET_EXP) | (F(a)<<3);
      shift = E(b)-E(a);
      sign = S(b);
      exp  = E(b);
    }
    
    for(i=0;i<shift;++i){       /* forだとやばい */
      loser = (loser>>1) | (loser&bit(0));
    }
    sum = winer - loser;

    if(sum&bit(3+OFFSET_EXP)){  /* 桁下がりなし */
      R   = sum&(bit(0)|bit(1));
      G   = sum&bit(2);
      ulp = sum&bit(3);
      if(G&&(ulp||R)) sum += bit(3); /* round to even */
      if(sum&bit(4+OFFSET_EXP)){     /* 1.11111111111から桁上がり */
        exp += 1;
        sum = sum >> 1;
      }
    }else if(sum&bit(2+OFFSET_EXP)){ /* ちょうど１桁桁下がり */
      sum = sum << 1;
      exp -= 1;
      R   = sum&(bit(0)|bit(1));
      G   = sum&bit(2);
      ulp = sum&bit(3);
      if(G&&(ulp||R)) sum += bit(3); /* round to even */
            if(sum&bit(4+OFFSET_EXP)){     /* 1.11111111111から桁上がり */
        exp += 1;
        sum = sum >> 1;
      }
    }else{                           /* ２桁以上桁下がり->有効桁数が24桁未満->丸めなし */
      for(i=0;i<1+OFFSET_EXP;++i){   /* for文はやばい */
        sum = sum << 1;
        exp -= 1;
        if(exp==0) return (sign<<OFFSET_SIGN) | Zero;/* 非正規化数はとりあえず(+-)0 */
        if(sum&bit(3+OFFSET_EXP))break;
      }
      if(i==i+OFFSET_EXP) return (sign<<MASK_SIGN) | Zero;/* 仮数にビットが無いので0 */
    }
    return (sign<<OFFSET_SIGN) | (exp<<OFFSET_EXP) | ((sum>>3)&MASK_FRAC);
  }
  return Zero;
}

static void show_binary(unsigned long long b,char buf[]){
  int i;
  for(i=0;i<32;++i){
    putc((int)'0' + ((b>>(31-i)) & 1),stdout );
    if(OFFSET_SIGN==31-i || OFFSET_EXP==31-i)
      putc(' ',stdout);
  }
  printf(":%s\n",buf);
}

static inline unsigned long long mask(unsigned long long x,unsigned long long y){
  return ((1ull<<(x+1ull))-1) - ((1ull<<y)-1);
}

static inline unsigned long long bit(unsigned long long x){
  return mask(x,x);
}

static inline unsigned long long S(unsigned long long x){
  return (x&MASK_SIGN)>>OFFSET_SIGN;
}

static inline unsigned long long E(unsigned long long x){
  return (x&MASK_EXP)>>OFFSET_EXP;
}

static inline unsigned long long F(unsigned long long x){
  return x&MASK_FRAC;
}
 
static inline int is_NaN(uint32_t x){
  return E(x)==0xff && F(x)!=0;
}
