#include"Matrix.hpp"
#include<iostream>
#include<random>
#include<iomanip>
using namespace std;

#define rep(i,n) for( int i = 0 ; i < (n) ; ++i )

int main(){
  random_device rd;
  mt19937_64 mt(rd());
  uniform_real_distribution<double> uniform(-10.,10.);

  cout << scientific << setprecision(4) << showpos ;
  int n = 6;
  Matrix<double> A(n,n),ans(n);
  rep(i,n)rep(j,n)A(i,j)=1.0/(i+j+1);
  rep(i,n) ans(i)=uniform(mt);
  Matrix<double> b = A*ans;
  LU_Matrix<double> LU = LU_decomposition(A);
  Matrix<double> x = LU.solve(b);

  cout << "A=\n" << A << endl;
  cout << "L*U-A=\n" << LU.revert()-A << endl;
  cout << "\nsolve Ax=b\nx-ans=\n" << x-ans << endl;
  cout << "\n||x-ans||/||ans||=" << (x-ans).norm()/ans.norm() << endl;
  return 0;
}
