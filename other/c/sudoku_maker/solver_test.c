#include"solver.h"
#include <stdio.h>

int main(){
  char input[100];
  int i,j;
  sudoku s;
  printf("Input a sudoku problem as the example\n");
  printf("003406009\n400700003\n...\n");
  for( i=0 ; i<9 ; ++ i){
    scanf("%s",input);
    for( j=0 ; j<9 ; ++j){
      s.masu[i*9 + j] = input[j] - '0';
    }
  }
  sudoku_answer ans = solver(s);

  printf("---answer---\n");
  for( i=0 ; i<9 ; ++ i){
    for( j=0 ; j<9 ; ++j){
      printf("%d",ans.masu[i*9+j]);
    }
    printf("\n");
  }
  printf("unique = %d\n",ans.unique);
  return 0;
}
