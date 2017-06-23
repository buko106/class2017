#include<iostream>
#include<vector>
using namespace std;
typedef vector<double> poly;

poly operator+(const poly &x,const poly &y){
  poly ret(max(x.size(),y.size()) , 0.0);
  for( int i = 0 ; i < x.size() ; ++i ){
    ret[i] += x[i];
  }
  for( int i = 0 ; i < y.size() ; ++i ){
    ret[i] += y[i];
  }
  return ret;
}

poly operator*(const poly &x,double a){
  poly ret(x.size());
  int n = x.size();
  for( int i = 0 ; i < n ; ++i )
    ret[i] = a * x[i];
  return ret;
}

poly x(const poly &x){
  poly ret=x;
  ret.insert(ret.begin(),0.0);
  return ret;
}

double subst(const poly &p,double x){
  int n = p.size();
  double ret = p[n-1];
  if( n == 1 ) return p[0];
  for( int i = n-1 ; i >= 1 ; --i ){
    ret = p[i-1] + x*ret;
  }
  return ret;
}

int main(){
  poly P[11]; // P0 ~ P10
  
  P[0].resize(1); P[0][0]=1.0; // P[0]=1
  P[1].resize(2); P[1][0]=0.0; P[1][1]=1.0; // P[1]=x
  for(int i=2 ; i<=10; ++i ) P[i].resize(i+1);
  for( int i = 1 ; i<10 ; ++i ){// generate P[2]~P[10]
    double n = i;
    P[i+1] = x(P[i])*((2*n+1)/(n+1)) + P[i-1]*(-n/(n+1));
  }
  for( int i = 0 ; i<=10 ; ++i ){
    // cout << "P[" << i << "]=" ;
    // for( int j = P[i].size()-1 ; j >= 0 ; --j ){
    //   cout << " " << P[i][j] ;
    // }
    // cout << endl;
    for( int j = -1000 ; j <= 1000 ; ++j ){
      double x = j/1000.0;
      cout << x << " " << subst(P[i],x) << endl;
    }
    cout << "\n\n" ;
  }

  return 0;
}
