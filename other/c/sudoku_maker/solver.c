#include "solver.h"

#define TRUE  1
#define FALSE 0

int masu[81];
int first_answer[81];
int num;
int column[9][10];// [0:8][1:9]
int row[9][10];   // [0:8][1:9]
int block[9][10]; // [0:8][1:9]

int to_column(int n){return n%9;}
int to_row   (int n){return n/9;}
int to_block (int n){return n/27*3 + n%9/3;}

int init_problem(void){
  int i,j;
  for( i=0 ; i<81 ; ++i ){
    if( masu[i] < 0 || masu[i] > 9 ) return masu[i];
  } // 0~9以外があったら不正。その値をリターン
  for( i=0 ; i<9 ; ++i ){
    for( j=1 ; j<=9; ++j){
      column[i][j] = 0;
      row[i][j] = 0;
      block[i][j] = 0;
    }
  } // 初期化
  for( i=0 ; i<81 ; ++i ){
    column[to_column(i)][masu[i]] ++ ;
    row[to_row(i)][masu[i]] ++ ;
    block[to_block(i)][masu[i]] ++ ;
  }// マスに使用済み登録
  for( i=0 ; i<9 ; ++i ){
    for( j=1 ; j<=9; ++j){
      if(column[i][j] > 1) return j;
      if(row[i][j] > 1) return j;
      if(block[i][j] > 1) return j;
    }
  } //不正な番号があったらそれをリターン
  return 0; // 正常終了
}
#include<stdio.h>
static void solve_n(int n){ // nマス目の処理
  int i;
  //
  /* int j; */
  /* printf("n=%d\n",n); */
  /* for( i=0 ; i<9 ; ++ i){ */
  /*   for( j=0 ; j<9 ; ++j){ */
  /*     printf("%d",masu[i*9+j]); */
  /*   } */
  /*   printf("\n"); */
  /* } */

  //
  if(n==81){
    ++ num;
    if(num>2) return;

    for( i=0 ; i<81 ; ++i) first_answer[i] = masu[i];
    return;
  } // 終了の処理

  if(masu[n] != 0){
    solve_n(n+1);
    return ;
  } // 埋まっていた

  for( i=1 ; i<=9 ; ++i){
    if( column[to_column(n)][i] == 0 &&
        row[to_row(n)][i] == 0 &&
        block[to_block(n)][i] == 0 ){// iで埋められるとき
      masu[n] = i;
      column[to_column(n)][i] = 1;
      row[to_row(n)][i] = 1;
      block[to_block(n)][i] = 1;

      solve_n(n+1);

      column[to_column(n)][i] = 0;
      row[to_row(n)][i] = 0;
      block[to_block(n)][i] = 0;
      masu[n] = 0;
    }
  }
  return ;
}

static void solve(void){
  solve_n(0);
  return ;
}

sudoku_answer solver(sudoku s){
  //解答が存在する問題に対しては、正しい解の１つと解がuniqueかどうかの真理値を返す。無効な問題に対しては問題そのものを返し、uniqueでは無いと返す。
  int i;
  sudoku_answer answer;
  answer.unique = TRUE;
  num = 0;
  for( i = 0 ; i < 81 ;  ++i ){
    masu[i] = s.masu[i] ;
  }

  if( 0 != init_problem()){
    for( i=0 ; i<81 ; ++i ) answer.masu[i] = s.masu[i];
    answer.unique = FALSE ;
    
    return answer;
  }

  solve();

  if(num == 0){
    for( i=0 ; i<81 ; ++i ) answer.masu[i] = s.masu[i];
    answer.unique = FALSE ;
  }else if(num == 1){
    for( i=0 ; i<81 ; ++i ) answer.masu[i] = first_answer[i];
    answer.unique = TRUE ;
  }else{ // num > 2
    for( i=0 ; i<81 ; ++i ) answer.masu[i] = first_answer[i];
    answer.unique = FALSE;
  }
  return answer;
}

