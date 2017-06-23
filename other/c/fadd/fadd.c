/*
  05-161026 平出一郎
  fadd.c
  round to even にしました。
 */
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
static unsigned long long at(unsigned long long,unsigned long long);
static unsigned long long downto(unsigned long long,unsigned long long,unsigned long long);
static unsigned long long S(unsigned long long);
static unsigned long long E(unsigned long long);
static unsigned long long F(unsigned long long);
static int is_NaN(uint32_t);
static unsigned long long rightshift24_with_roundbit(unsigned long long,unsigned long long);
static unsigned long long rightshift25_with_roundbit(unsigned long long,unsigned long long);

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
    }
    else{
      winer = bit(2+OFFSET_EXP) | (F(b)<<2);
      loser = bit(2+OFFSET_EXP) | (F(a)<<2);
      shift = E(b)-E(a);
      sign = S(b);
      exp = E(b);
    }

    /* for(i=0;i<shift;++i){         /\* forだとやばそう *\/ */
    /*   loser = (loser>>1) | (loser&bit(0)); */
    /* } */
    loser = rightshift24_with_roundbit(loser,shift);

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
  }
  else{                        /* 異符号->sub */
    if((a&(MASK_EXP|MASK_FRAC))==(b&(MASK_EXP|MASK_FRAC))){
      return Zero;/* 正負で同じ大きさ */
    }
    else if((a&(MASK_EXP|MASK_FRAC))>(b&(MASK_EXP|MASK_FRAC))){
      /* aが絶対値大きい */
      winer = bit(3+OFFSET_EXP) | (F(a)<<3);
      loser = bit(3+OFFSET_EXP) | (F(b)<<3);
      shift = E(a)-E(b);
      sign = S(a);
      exp  = E(a);
    }
    else{
      winer = bit(3+OFFSET_EXP) | (F(b)<<3);
      loser = bit(3+OFFSET_EXP) | (F(a)<<3);
      shift = E(b)-E(a);
      sign = S(b);
      exp  = E(b);
    }
    
    /* for(i=0;i<shift;++i){       /\* forだとやばそう *\/ */
    /*   loser = (loser>>1) | (loser&bit(0)); */
    /* } */
    loser = rightshift25_with_roundbit(loser,shift);
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

static unsigned long long rightshift24_with_roundbit(unsigned long long x,unsigned long long shift){
  switch(shift){
  case 0 : return x;
  case 1 : return (x>>1) | (downto(x,1,0)?1ull:0ull);
  case 2 : return (x>>2) | (downto(x,2,0)?1ull:0ull);
  case 3 : return (x>>3) | (downto(x,3,0)?1ull:0ull);
  case 4 : return (x>>4) | (downto(x,4,0)?1ull:0ull);
  case 5 : return (x>>5) | (downto(x,5,0)?1ull:0ull);
  case 6 : return (x>>6) | (downto(x,6,0)?1ull:0ull);
  case 7 : return (x>>7) | (downto(x,7,0)?1ull:0ull);
  case 8 : return (x>>8) | (downto(x,8,0)?1ull:0ull);
  case 9 : return (x>>9) | (downto(x,9,0)?1ull:0ull);
  case 10: return (x>>10) | (downto(x,10,0)?1ull:0ull);
  case 11: return (x>>11) | (downto(x,11,0)?1ull:0ull);
  case 12: return (x>>12) | (downto(x,12,0)?1ull:0ull);
  case 13: return (x>>13) | (downto(x,13,0)?1ull:0ull);
  case 14: return (x>>14) | (downto(x,14,0)?1ull:0ull);
  case 15: return (x>>15) | (downto(x,15,0)?1ull:0ull);
  case 16: return (x>>16) | (downto(x,16,0)?1ull:0ull);
  case 17: return (x>>17) | (downto(x,17,0)?1ull:0ull);
  case 18: return (x>>18) | (downto(x,18,0)?1ull:0ull);
  case 19: return (x>>19) | (downto(x,19,0)?1ull:0ull);
  case 20: return (x>>20) | (downto(x,20,0)?1ull:0ull);
  case 21: return (x>>21) | (downto(x,21,0)?1ull:0ull);
  case 22: return (x>>22) | (downto(x,22,0)?1ull:0ull);
  case 23: return (x>>23) | (downto(x,23,0)?1ull:0ull);
  case 24: return (x>>24) | (downto(x,24,0)?1ull:0ull);
  }
  return 0;   /* 25桁シフトするとRビットに関係なく足し算は+0と同義になる */
}

static unsigned long long rightshift25_with_roundbit(unsigned long long x,unsigned long long shift){
  switch(shift){
  case 0 : return x;
  case 1 : return (x>>1) | (downto(x,1,0)?1ull:0ull);
  case 2 : return (x>>2) | (downto(x,2,0)?1ull:0ull);
  case 3 : return (x>>3) | (downto(x,3,0)?1ull:0ull);
  case 4 : return (x>>4) | (downto(x,4,0)?1ull:0ull);
  case 5 : return (x>>5) | (downto(x,5,0)?1ull:0ull);
  case 6 : return (x>>6) | (downto(x,6,0)?1ull:0ull);
  case 7 : return (x>>7) | (downto(x,7,0)?1ull:0ull);
  case 8 : return (x>>8) | (downto(x,8,0)?1ull:0ull);
  case 9 : return (x>>9) | (downto(x,9,0)?1ull:0ull);
  case 10: return (x>>10) | (downto(x,10,0)?1ull:0ull);
  case 11: return (x>>11) | (downto(x,11,0)?1ull:0ull);
  case 12: return (x>>12) | (downto(x,12,0)?1ull:0ull);
  case 13: return (x>>13) | (downto(x,13,0)?1ull:0ull);
  case 14: return (x>>14) | (downto(x,14,0)?1ull:0ull);
  case 15: return (x>>15) | (downto(x,15,0)?1ull:0ull);
  case 16: return (x>>16) | (downto(x,16,0)?1ull:0ull);
  case 17: return (x>>17) | (downto(x,17,0)?1ull:0ull);
  case 18: return (x>>18) | (downto(x,18,0)?1ull:0ull);
  case 19: return (x>>19) | (downto(x,19,0)?1ull:0ull);
  case 20: return (x>>20) | (downto(x,20,0)?1ull:0ull);
  case 21: return (x>>21) | (downto(x,21,0)?1ull:0ull);
  case 22: return (x>>22) | (downto(x,22,0)?1ull:0ull);
  case 23: return (x>>23) | (downto(x,23,0)?1ull:0ull);
  case 24: return (x>>24) | (downto(x,24,0)?1ull:0ull);
  case 25: return (x>>25) | (downto(x,25,0)?1ull:0ull);
  }
  return 0;   /* 26桁シフトするとRビットに関係なく引き算は-0と同義になる */
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
  return 1ull << x;
}

static inline unsigned long long at(unsigned long long x,unsigned long long pos){
  return (x&bit(pos))>>pos;
}

static inline unsigned long long downto(unsigned long long x,unsigned long long M,unsigned long long L){
  return (x&mask(M,L))>>L;
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
