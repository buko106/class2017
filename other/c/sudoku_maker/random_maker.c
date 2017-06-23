#include<stdlib.h>
#include<stdio.h>
#include<time.h>
#include"solver.h"

int masu[81];
int column[9][10];
int row[9][10];
int block[9][10];
int problem_number=0;
int end_flag;
int rand_seq[9];

#define TRUE  1
#define FALSE 0

void output_problem(void){
  char number[1000]="problem/";
  sprintf(number+8,"%d.txt",problem_number);
  problem_number ++ ;
  FILE* out = fopen(number,"w");
  printf("%s",number);
  if( NULL == out ){ fprintf(stderr,"fopen error\n"); exit(1);}
  int i;
  for( i=0 ; i<81 ; ++i ){
    fprintf(out,"%d",masu[i]);
    if(i%9  == 8) fprintf(out,"\n");
  }
  fclose(out);
  return;
}

void copy_to_sudoku(sudoku *s){
  int i;
  for( i=0 ; i<81 ; ++i)
    s->masu[i] = masu[i];
  return;
}

void set_rand_seq(void){
  int used[10]={};
  int i,n;
  for( i=0 ; i<9 ; ++i ){
    while( n=rand()%9 + 1 , used[n] == TRUE);
    rand_seq[i] = n;
    used[n] = TRUE;
  }
  return;
}

void maker(int n){
  int i,rm;

  if(end_flag) return;
  
  if( n==81 ){
    printf("n==81\n");
    sudoku s;
    sudoku_answer ans;
    for( i=0 ; i<81 ; ++i){
      while(rm=rand()%81,masu[rm]==0);
      s.masu[rm] = masu[rm];
      masu[rm] = 0;
      printf("call solver(s)\n");
      ans = solver(s);
      if(ans.unique){
        output_problem();
        end_flag = TRUE;
        break;
      }
    }
    return;
  } // 順番に消してみてuniqueなものができたら、出力、うれしい。ダメだったらすてる
  
  set_rand_seq();
  for( i=0 ; i<9 ;++i ){
    int k=rand_seq[i];
    if( column[to_column(n)][k] == 0 &&
        row[to_row(n)][k] == 0 &&
        block[to_block(n)][k] == 0){
      masu[n] = k;
      column[to_column(n)][k] = 1;
      row[to_row(n)][k] = 1;
      block[to_block(n)][k] = 1;

      maker(n+1);

      column[to_column(n)][k] = 0;
      row[to_row(n)][k] = 0;
      block[to_block(n)][k] = 0;
      masu[n] = 0;
    }
  }
}

void random_maker(){
  int i,j;
  end_flag = FALSE;

  while(FALSE == end_flag){
    for( i=0 ; i<81 ; ++i ) masu[i] = 0;
    for( i=0 ; i<9 ;++i ){
      for( j=1 ; j<=9 ;++j ){
        column[i][j]=0;
        row[i][j]=0;
        block[i][j]=0;
      }
    }
    maker(0);
  }
  return ;
}

int main(){
  int n,i;
  printf("Input the number of problems:");
  scanf("%d",&n);
  srand(time(NULL));
  for(i=0;i<n;++i){
    random_maker();
  }
  return 0;
}
