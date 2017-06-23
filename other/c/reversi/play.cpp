#include<string>
#include<cstdlib>
#include<cstdint>
#include<vector>
#include<algorithm>
#include<iostream>
#include"play.hpp"
using namespace std;

#define MAX_EVAL 1000000000

static inline uint64_t valid_some_moves( const uint64_t black , const uint64_t mask , const int dir){
  register uint64_t flip = mask & ((black << dir) | (black >> dir));
  flip |= mask & ((flip << dir) | (flip >> dir));
  flip |= mask & ((flip << dir) | (flip >> dir));
  flip |= mask & ((flip << dir) | (flip >> dir));
  flip |= mask & ((flip << dir) | (flip >> dir));
  flip |= mask & ((flip << dir) | (flip >> dir));
  return (flip << dir) | (flip >> dir);
}

uint64_t valid_moves( const uint64_t black , const uint64_t white ){
  return (~(black|white)) &
    (valid_some_moves(black,white&0x7e7e7e7e7e7e7e7eull,1)|
     valid_some_moves(black,white&0x00ffffffffffff00ull,8)|
     valid_some_moves(black,white&0x007e7e7e7e7e7e00ull,7)|
     valid_some_moves(black,white&0x007e7e7e7e7e7e00ull,9));
}

static inline int popcount(uint64_t x) 
{ 
  x = ((x & 0xaaaaaaaaaaaaaaaaUL) >> 1) 
    +  (x & 0x5555555555555555UL); 
  x = ((x & 0xccccccccccccccccUL) >> 2) 
    +  (x & 0x3333333333333333UL); 
  x = ((x & 0xf0f0f0f0f0f0f0f0UL) >> 4) 
    +  (x & 0x0f0f0f0f0f0f0f0fUL); 
  x = ((x & 0xff00ff00ff00ff00UL) >> 8) 
    +  (x & 0x00ff00ff00ff00ffUL); 
  x = ((x & 0xffff0000ffff0000UL) >> 16) 
    +  (x & 0x0000ffff0000ffffUL); 
  x = ((x & 0xffffffff00000000UL) >> 32) 
    +  (x & 0x00000000ffffffffUL); 
  return x;
} 

static inline uint64_t get_some_rev_left( uint64_t black , uint64_t white , uint64_t mv , uint64_t guard , int dir ){
  register uint64_t rev = 0x0ull;
  register uint64_t mask= (mv<<dir) & guard;
  while(mask && (mask & white)){
    rev = rev | mask;
    mask= (mask<<dir) & guard;
  }
  if( mask & black ) return rev;
  return 0x0ull;
}

static inline uint64_t get_some_rev_right( uint64_t black , uint64_t white , uint64_t mv , uint64_t guard , int dir ){
  register uint64_t rev = 0x0ull;
  register uint64_t mask= (mv>>dir) & guard;
  while(mask && (mask & white)){
    rev = rev | mask;
    mask= (mask>>dir) & guard;
  }
  if( mask & black ) return rev;
  return 0x0ull;
}

uint64_t get_rev( uint64_t black , uint64_t white , uint64_t mv){
  /* mv must be valid move */
  /* does not include mv*/
  return
    get_some_rev_right(black,white,mv,0x7f7f7f7f7f7f7f7full,1)|
    get_some_rev_right(black,white,mv,0x00ffffffffffffffull,8)|
    get_some_rev_right(black,white,mv,0x00fefefefefefefeull,7)|
    get_some_rev_right(black,white,mv,0x007f7f7f7f7f7f7full,9)|
    get_some_rev_left (black,white,mv,0xfefefefefefefefeull,1)|
    get_some_rev_left (black,white,mv,0xffffffffffffff00ull,8)|
    get_some_rev_left (black,white,mv,0x7f7f7f7f7f7f7f00ull,7)|
    get_some_rev_left (black,white,mv,0xfefefefefefefe00ull,9);
}




static string to_str(int x, int y)
{
  const char *t = "abcdefgh", *s = "12345678";
  return string(1, t[x]) + string(1, s[y]);
}

int pos_val[80] = {  30 , -22 ,   0 ,  -2 ,
                          -25 ,  -3 ,  -3 ,
                                  0 ,  -2 ,
                                       -2 ,
                     30 , -22 ,   0 ,  -2 ,
                          -25 ,  -3 ,  -3 ,
                                  0 ,  -2 ,
                                       -2 ,
                    100 , -22 ,   0 ,  -2 ,
                          -25 ,  -3 ,  -3 ,
                                  0 ,  -2 ,
                                       -2 ,
                    100 , -22 ,   0 ,  -2 ,
                          -25 ,  -3 ,  -3 ,
                                  0 ,  -2 ,
                                       -2 ,
                    100 , -22 ,   0 ,  -2 ,
                          -25 ,  -3 ,  -3 ,
                                  0 ,  -2 ,
                                       -2 ,
                    100 , -22 ,   0 ,  -2 ,
                          -25 ,  -3 ,  -3 ,
                                  0 ,  -2 ,
                                       -2 ,
                    100 , -22 ,   0 ,  -2 ,
                          -25 ,  -3 ,  -3 ,
                                  0 ,  -2 ,
                                       -2 ,
                     30 , -22 ,   0 ,  -2 ,
                          -25 ,  -3 ,  -3 ,
                                  0 ,  -2 ,
                                       -2 };

int move_val[80] ={  80 ,   0 ,   5 ,   0 ,
                            0 ,   0 ,   0 ,
                                  5 ,   0 ,
                                        0 ,
                     80 ,   0 ,   5 ,   0 ,
                            0 ,   0 ,   0 ,
                                  5 ,   0 ,
                                        0 ,
                     80 ,   0 ,   5 ,   0 ,
                            0 ,   0 ,   0 ,
                                  5 ,   0 ,
                                        0 ,
                     80 ,   0 ,   5 ,   0 ,
                            0 ,   0 ,   0 ,
                                  5 ,   0 ,
                                        0 ,
                     80 ,   0 ,   5 ,   0 ,
                            0 ,   0 ,   0 ,
                                  5 ,   0 ,
                                        0 ,
                     80 ,   0 ,   5 ,   0 ,
                            0 ,   0 ,   0 ,
                                  5 ,   0 ,
                                        0 ,
                     80 ,   0 ,   5 ,   0 ,
                            0 ,   0 ,   0 ,
                                  5 ,   0 ,
                                        0 ,
                     80 ,   0 ,   5 ,   0 ,
                            0 ,   0 ,   0 ,
                                  5 ,   0 ,
                                        0 };


int num_to_pos[64] = {0 , 1 , 2 , 3 , 3 , 2 , 1 , 0 ,
                      1 , 4 , 5 , 6 , 6 , 5 , 4 , 1 ,
                      2 , 5 , 7 , 8 , 8 , 7 , 5 , 2 ,
                      3 , 6 , 8 , 9 , 9 , 8 , 6 , 3 ,
                      3 , 6 , 8 , 9 , 9 , 8 , 6 , 3 ,
                      2 , 5 , 7 , 8 , 8 , 7 , 5 , 2 ,
                      1 , 4 , 5 , 6 , 6 , 5 , 4 , 1 ,
                      0 , 1 , 2 , 3 , 3 , 2 , 1 , 0 };


int eval( uint64_t black , uint64_t white ){
  int sum = 0;
  int phase = popcount( black|white )/8 ; // 0..8
  
  if( phase == 8 ){
    int count_b = popcount(black);
    int count_w = popcount(white);
    if( count_b > count_w ) return MAX_EVAL + (count_b-count_w);
    else if( count_b < count_w ) return -MAX_EVAL - (count_w-count_b);
    else return 0;
  }
  
  uint64_t pos = 0x8000000000000000ull;
  int vm_black = valid_moves(black,white);
  int vm_white = valid_moves(white,black);
  for( int i = 0 ; i < 64 ; ++i ){
    int idx = num_to_pos[i] + 10*phase;
    // stone value
    if( black & pos )
      sum += pos_val[idx];
    else if( white & pos )
      sum -= pos_val[idx];

    // weighted mombility
    if( vm_black & pos )
      sum += move_val[idx];
    if( vm_white & pos )
      sum -= move_val[idx];
    pos >>= 1;
  }
  return sum;
}


int negaalpha( uint64_t black , uint64_t white , int depth , int alpha , int beta ){
  if( depth == 0 ) return eval( black , white );
  
  uint64_t vm = valid_moves(black,white);
  if( vm ){                     // 打てる
    int score;
    int score_max = -MAX_EVAL-100;
    int a = alpha;
    
    uint64_t pos = 0x1ull;
    while( pos ){
      if( vm & pos ){
        uint64_t rev = get_rev(black,white,pos);
        score=-negaalpha( white^rev , black^(pos|rev) , depth-1 , -beta , a);
        
        if(score >= beta) return score;
        if(score > score_max){
          a = max(a,score);
          score_max = score;
        }
      }
      pos <<= 1;
    }
    return score_max;
  }else{// 合法手なし
    if( 0x0ull == valid_moves(white,black) ){ // 決着している
      int b = popcount(black);
      int w = popcount(white);
      if( b > w ) return MAX_EVAL + (b-w); //  b-w 差で勝ち
      else if(b < w) return -MAX_EVAL - (w-b);// w-b 差で負け
      else return 0;                          // 引き分け
    }else{                                    // パス
      return -negaalpha( white , black , depth-1 , -beta , -alpha );
    }
  }
}

uint64_t play( const uint64_t player , const uint64_t opponent ){
  uint64_t vm = valid_moves(player,opponent);
  // pass
  if( vm == 0x0ull ) return 0x0ull;

  uint64_t pos= 0x8000000000000000ull;
  uint64_t rev;
  int stones = popcount( player|opponent);
  vector< pair<int,uint64_t> > val_mv;
  for(int i=0; i<64 ; ++i , pos >>= 1){
    if ( pos & vm ){
      int depth;
      if( stones >= 50) depth = 14;
      else if( stones >= 46 ) depth = 12;
      else                  depth = 10;
      rev = get_rev( player , opponent , pos);

      
      val_mv.push_back
        (make_pair( negaalpha( opponent^rev , player^(rev|pos) , depth , -MAX_EVAL-100 , MAX_EVAL + 100) , pos ));
    }
  }

  srand(time(NULL));

  sort(val_mv.begin(),val_mv.end());


  int num_of_best = 1;
  for(  ;  num_of_best < (int)val_mv.size() ; num_of_best++){
    if( val_mv[0].first != val_mv[num_of_best].first )
      break;
  }


  return val_mv[rand()%num_of_best].second;
}
