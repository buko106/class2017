#include<stdio.h>

typedef double real;

void mult( int n , int m , int l , real A[n][m] , real B[m][l] , real C[n][l] ){
  for( int i = 0 ; i < n ; ++i ){
    for( int j = 0 ; j < l ; ++j ){
      C[i][j] = 0;
      for( int k = 0 ; k < m ; ++k ){
        C[i][j] += A[i][k] * B[k][j];
      }
    }
  }
  return;
}

int main(){
  int n = 2;
  int m = 4;
  int l = 3;
  real A[n][m],B[m][l],C[n][l];

  for( int i = 0 ; i < n ; ++i )
    for( int j = 0 ; j < m ; ++j )
      A[i][j] = (real)(i-j+1);
  for( int i = 0 ; i < m ; ++i )
    for( int j = 0 ; j < l ; ++j )
      B[i][j] = (real)(i-j+1);

  printf("A =\n");
  for( int i = 0 ; i < n ; ++i ){
    for( int j = 0 ; j < m ; ++j ){
      printf(" %+le",A[i][j]);
    }
    printf("\n");
  }
  printf("B =\n");
  for( int i = 0 ; i < m ; ++i ){
    for( int j = 0 ; j < l ; ++j ){
      printf(" %+le",B[i][j]);
    }
    printf("\n");
  }

  mult(n,m,l,A,B,C);

  printf("C = A*B =\n");
  for( int i = 0 ; i < n ; ++i ){
    for( int j = 0 ; j < l ; ++j ){
      printf(" %+le",C[i][j]);
    }
    printf("\n");
  }

  return 0;
}
