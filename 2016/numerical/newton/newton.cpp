#include <iostream>
#include <iomanip>
#include <cmath>
using namespace std;

const double pi  = acos(-1.0);
const double ans = pow(log(pi),0.25);
const double eps = 1.0e-15;

double f(double x){
  double x2=x*x;
  double x4=x2*x2;
  return exp(x4) - pi;
}

double df(double x){
  double x2=x*x;
  double x3=x2*x;
  double x4=x2*x2;
  return 4.0*x3*exp(x4);
}

pair<double,int> newton(double x,int iter){
  int i;
  for( i=0 ; i<iter ; ++i ){
    if( abs(x-ans) < eps ) break;
    x = x - f(x)/df(x);
  }
  return make_pair(x,i);
}

int main(){
  ios::sync_with_stdio(false);

  pair<double,int> a;
  for( int i=1 ; i<=10000 ; ++i ){
    a.first = i/1000.0;
    a.second= 2000;
    a = newton(a.first,a.second);
    cout << i/1000.0 << " " << a.second << " " << a.first << endl;
  }

  return 0;
}
