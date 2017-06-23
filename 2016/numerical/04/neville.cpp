#include<iostream>
#include<cmath>
#include<vector>
using namespace std;

inline double F(int n,double x){
  if( n <= 0 ) return 1.0;

  return 1.0 + x * F(n-1,x);
}

double neville( vector< pair<double,double> > xys , double x){
  const int n = xys.size();
  vector< vector<double> > c(n);
  for( int i = 0 ; i < c.size() ; ++i ) c[i].resize(n);

  for( int j = 0 ; j <= n-1 ; ++j ){
    for( int k = 0 ; k <= n-j-1 ; ++k ){
      if( j == 0 ) c[j][k] = xys[k].second;
      else c[j][k] = (c[j-1][k]-c[j-1][k+1])/(xys[k].first-xys[k+j].first);
    }
  }

  double ret = c[n-1][0];
  for( int j = 0 ; j < n-1 ; ++j ){
    ret = ret * (x-xys[n-j-2].first) + c[n-j-2][0] ;
  }
  return ret;
}

int main(){
  vector< pair<double,double> > f[8],e,l;
  double sample = 0.75;
  for( int i = 5 ; i <= 10 ; ++i ){
    double x = (double)i / 10.0;
    for( int n = 2 ; n <= 7 ; ++n ){
      f[n].push_back(make_pair(x,F(n,x)));
    }
    e.push_back(make_pair(x,exp(x)));
    l.push_back(make_pair(x,log(x)));
  }

  cout << "name: neville true-value absolute relative" << endl;
  for( int n = 2 ; n <= 7 ; ++ n ){
    double result = neville(f[n],sample);
    cout << "F[" << n << "]: "  << result << " " << F(n,sample) << " " << abs(result-F(n,sample)) << " " << abs((result-F(n,sample))/F(n,sample)) << endl;
  }
  double result_e = neville(e,sample);
  cout << "exp: " << result_e << " " << exp(sample) << " " << abs(result_e-exp(sample)) << " " << abs((result_e-exp(sample))/exp(sample)) << endl;
  double result_l = neville(l,sample);
  cout << "log: " << result_l << " " << log(sample) << " " << abs(result_l-log(sample)) << " " << abs((result_l-log(sample))/log(sample))<< endl;
  return 0;
}
