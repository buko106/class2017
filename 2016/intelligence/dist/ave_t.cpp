#include<random>
#include<iostream>
using namespace std;

mt19937 mt;
normal_distribution<double> std_norm(0.0,1.0);

double chi2(int n){
  double ret=0.0;
  for( int i = 0 ; i < n ; ++i ){
    double x = std_norm(mt);
    ret += x*x;
  }
  
  return ret;
}

double t(int n){
  double x = std_norm(mt);
  double y = chi2(n);
  return x/sqrt(y/n);
}

double ave_t(int n){
  double sum=0.0;
  for( int i = 0 ; i < n ; ++i )
    sum += t(2);
  return sum/n;
}

int main(){
  ios::sync_with_stdio(false);
  
  const int ITER = 100000;
  random_device rnd;
  mt.seed(rnd());
  
  int n;
  cin >> n;

  for( int i = 1 ; i <= ITER ; ++i ){
    cout << ave_t(n) << endl;
  }
  return 0;
}
