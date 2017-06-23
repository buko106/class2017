#include<iostream>
#include<valarray>
using namespace std;

typedef valarray<double> vec;

double f(vec x){return 10.0 * x[0] * x[0] + x[1] * x[1];}
vec grad(vec x){ vec g = {20.0*x[0],2.0*x[1]};return g;}
bool in(double a,double b,double c){
  return (a < b) && (b < c);
}

double norm(vec x){ return x[0]*x[0] + x[1]*x[1];}

int main(){
  ios::sync_with_stdio(false);
  double alpha,beta;
  cerr << "alpha:" << flush;
  cin >> alpha ;
  cerr << "beta:" << flush;
  cin >> beta;
  if( ! (in(0.0,alpha,1.0) && in(0.0,beta,1.0)) ){
    cout << "alpha and beta must be in (0.0,1.0)" << endl;
    return 1;
  }

  double x1,x2;
  cerr << "x1:" << flush;
  cin >> x1 ;
  cerr << "x2:" << flush;
  cin >> x2;
  
  vec old_x = {0.0,0.0};
  vec x = {x1,x2};
  double eps;

  while(norm(x-old_x)>1.0E-25){
    cout << x[0] << " " << x[1] << endl;
    eps = 1.0;
    old_x = x;
    while( f(old_x - eps*grad(old_x)) - f(old_x)
           > - alpha * eps * norm(grad(old_x))){// Armijo
      eps = beta * eps;
    }
    x = old_x - eps * grad(old_x);
  }
  return 0;
}
