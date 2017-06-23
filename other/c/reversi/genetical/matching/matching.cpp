#include<algorithm>
#include<cstdint>
#include<cstdlib>
#include<ctime>
#include<iostream>
#include<vector>
#include"genetical_play.hpp"
using namespace std;

#define SIZE_OF_GENOME 160 


//typedef genome = vector<uint8_t> genome[160]

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

vector<uint8_t> crossover( vector<uint8_t> g1 , vector<uint8_t> g2 ){
  vector<uint8_t> result(SIZE_OF_GENOME,0);
  uint8_t mask;
  for( int i = 0 ; i < SIZE_OF_GENOME ; ++i ){
    mask = rand() & 0xff;
    result[i] = (g1[i]&mask) | (g2[i]&(~mask)) ;
  }

  return result;
}

int battle( const vector<uint8_t> black , const vector<uint8_t> white ){
  // 先手が黒、評価値は勝ちの場合  64-相手の石の数
  //                  負けの場合は   自分の石の数
  //                  引き分けの場合は32
  uint64_t pass = 0x0ull;
  uint64_t board_black = 0x0000000810000000ull;
  uint64_t board_white = 0x0000001008000000ull;
  uint64_t mv,rev;
  int flag = false ;//pass flag 
  while(true){
    mv = genetic_play( black , board_black , board_white );
    if( mv == pass ){//pass ( black )
      cerr << "pass" << endl;
      if( flag ) break;
      else flag = true;
    }else{ // move ( black )
      //cout << "move black" << endl;
      flag = false;
      rev = get_rev( board_black , board_white , mv );
      board_black ^= ( mv | rev );
      board_white ^= rev;
    }

    mv = genetic_play( white , board_white , board_black );
    if( mv == pass){//pass(white)
      cerr << "pass" << endl;
      if( flag ) break;
      else flag = true;
    }else{//move ( white )
      //cout << "move white" << endl;
      flag = false;
      rev = get_rev( board_white , board_black , mv );
      board_white ^= ( mv | rev );
      board_black ^= rev;
    }
  }
  int b = popcount( board_black );
  int w = popcount( board_white );
  if( b > w ) return 64-w;
  else if( b < w) return b;
  else return 32;
}

vector<int> matching( const vector< vector<uint8_t> > genome , int round){
  int n = genome.size();
  vector<int> sum(n,0);

  for( int i = 0 ; i < n ; ++i ){
    for( int j = i+1 ; j < n ; ++ j){
      cerr << "個体[" << i << "] vs 個体[" << j <<"]" << endl;
      for( int r = 0 ; r < round ; ++ r){
        int v1 = battle( genome[i] , genome[j] );
        cerr << v1 << " to " << 64-v1 << endl;
        int v2 = battle( genome[j] , genome[i] );
        cerr << 64-v2 << " to " << v2 << endl;

        sum[i] += v1 - v2 ;
        sum[j] += v2 - v1 ;
      }
    }
  }
  return sum;
}

vector<uint8_t> generate_random(){
  vector<uint8_t> genome(SIZE_OF_GENOME,0);
  for( int i = 0 ; i < SIZE_OF_GENOME ; ++i ){
    genome[i] = rand() & 0xff;
  }
  return genome;
}

const int num_of_generation = 10;

int rand_to_rank[55] =
  {0,0,0,0,0,0,0,0,0,0,
   1,1,1,1,1,1,1,1,1,
   2,2,2,2,2,2,2,2,
   3,3,3,3,3,3,3,
   4,4,4,4,4,4,
   5,5,5,5,5,
   6,6,6,6,
   7,7,7,
   8,8,
   9};

vector< vector<uint8_t> > next_generation( vector< vector<uint8_t> > genome){
  // 上位１個体を残し、あとの9個体はcrossoverによって生成
  // 10回に１回(最上位以外)どれか１体を改変（1byteにつきランダムに1bit反転させる）
  vector< pair< int , int > > rank;
  vector< int > result = matching( genome , 1 );
  //output result (begin)
  for( int i = 0 ; i < num_of_generation ; ++i){
    cout << "individual[" << i << "]score=" << result[i] << endl;
    for( int j = 0 ; j < SIZE_OF_GENOME ; ++j){
      if( j % 10 == 0 ) cout << endl;
      cout << (int)genome[i][j] << ' ' ;
    }
    cout << endl;
  }
  //output result (end)
  for( int i = 0 ; i < num_of_generation ; ++i )
    rank.push_back( make_pair(result[i] , i) );
  sort(rank.begin(),rank.end(),greater<pair<int,int>>());//降順（大きい順）
  
  vector< vector<uint8_t> > next;
  next.push_back(genome[rank[0].second]);
  for( int i = 0 ; i < num_of_generation - 1; ++i){
    next.push_back(crossover
                   (genome[rank[rand_to_rank[rand()%55]].second],
                    genome[rank[rand_to_rank[rand()%55]].second]));
  }
  return next;
}

int main(){
  vector< vector<uint8_t> > genome;
  srand(time(NULL));
  for( int i = 0 ; i < num_of_generation ; ++i ){
    genome.push_back( generate_random() );
  }

  for( int i = 1 ;  ;  ++ i ) {
    cout << "generation = " << i << endl;
    genome = next_generation(genome);
  }

  return 0;
}
