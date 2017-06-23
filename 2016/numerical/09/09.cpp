#include"Matrix.hpp"
#include<iostream>
#include<iomanip>
#include<random>
using namespace std;

int main(){
  random_device rd;
  mt19937_64 mt(rd());
  uniform_real_distribution<double> uni(-10.0,10.0);
  uniform_real_distribution<double> ratio(1.0,5.0);
  uniform_int_distribution<int> neg(0,1);
  cout << scientific << showpos << setprecision(3);

  int n = 10;
  Matrix<double> A(n,n);
  Matrix<double> b(n);
  // generate Matrix A, Vector b
  double sum = 0.0;
  for( int i = 0 ; i < n ; ++i ){
    b(i) = uni(mt);
    for( int j = 0 ; j < n ; ++j){
      if( i != j ) A(i,j) = uni(mt);
      else         A(i,j) = 0.;
      
      sum += abs(A(i,j));
    }
  }
  
  for( int i = 0 ; i < n ; ++i ){
    if( neg(mt) ) A(i,i) = - sum * ratio(mt);
    else          A(i,i) =   sum * ratio(mt);
  }

  // check
  // cout << "A=\n" << A << endl;

  // solve

  // make D_inv
  Matrix<double> D_inv(n,n,0.0);
  for( int i = 0 ; i < n ; ++i ){
    D_inv(i,i) = 1.0 / A(i,i) ; 
  }

  int iter = 15;
  Matrix<double> x(n,1,0.0);
  cout << "# iteration (b-A*x).norm()" << endl;
  for( int i = 0 ; i < iter ; ++i ){
    x = x + D_inv * ( b - A*x );
    cout << i << " " << (b-A*x).norm() << endl;
  }

  return 0;
}
