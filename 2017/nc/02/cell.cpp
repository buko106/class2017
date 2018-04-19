#include<iostream>
#include<vector>
#include<cstdlib>
#include<ctime>
using namespace std;

void show( vector<int> cell , bool showNum = true ){
  int n = cell.size();
  for( int i = 0 ; i < n ; ++i ){
    cout << (cell[i]==0 ? "_" : (cell[i]==1 ? "R" : "L" )) ;
  }
  if( showNum ){
    int sum = 0;
    for( int i = 0 ; i < n ; ++i ){
      sum += cell[i];
    }
    cout << "check_sum = " << sum ;
  }
  cout << endl;
  return;
}

int rule( int left , int center , int right ){
  if( left == 1 && ( center == 1 || ( center == 0 && right != -1 )) ){
    return 1;
  }else if( right == -1 && ( center == -1 || ( center == 0 && left != 1 )) ){
    return -1;
  }else{
    return 0;
  }
}

vector<int> step(vector<int> cell){
  int n = cell.size();
  vector<int> next(n,0);
  for( int i = 1 ; i < (n-1) ; ++i ){
    next[i] = rule( cell[i-1] , cell[i] , cell[i+1] );
  }
  return next;
}

int main(){
  int n = 100;
  srand(time(NULL));
  
  vector<int> cell(n,0);
  for( int i = 1 ; i < (n-1) ; ++i ){
    cell[i] = rand()%3 - 1;
  }
  for( int i = 0 ; i < n ; ++i ){
    cell = step(cell);
    show(cell);
  }
  return 0;
}
