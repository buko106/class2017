#include<complex>
#include<vector>
#include<cmath>
#include<iostream>
#include<sys/time.h>
using namespace std;

const double pi=acos(-1.0);
const double pi2 = 2.0 * pi;
const complex<double> zero( 0.0 , 0.0 );


vector< complex<double> > dft( vector< complex<double> > a){
  int T = a.size();
  
  vector< complex<double> > f(T,zero);
  for( int t = 0 ; t < T ; ++t ){
    double t_div_T = ((double)t) / T ;
    for( int n = 0 ; n < T ; ++n ){
      complex<double> tmp(0.0,-pi2*n*t_div_T);
      f[n] += a[t] * exp(tmp);
    }
  }
  return f;
}

vector< complex<double> > idft( vector< complex<double> > f){
  int T = f.size();
  
  vector< complex<double> > a(T,zero);
  for( int t = 0 ; t < T ; ++t ){
    double t_div_T = ((double)t) / T ;
    for( int n = 0 ; n < T ; ++n ){
      complex<double> tmp(0.0,pi2*n*t_div_T);
      a[t] += f[n] * exp(tmp);
    }
    a[t] /= T;
  }
  return a;
}

template<class T> void scramble( vector<T> &a ){
  int n = a.size(); // must be power of 2
  int i = 0;
  for( int j = 1; j < n-1 ; ++j ){
    for( int k = n>>1 ; k > (i ^= k ) ; k >>= 1 )
      ;
    if( j < i )
      swap(a[j],a[i]);
  }
  return;
}

inline complex<double> omega( int i , int T ){
  complex<double> tmp(0.0,(-pi2*i)/T);
  return exp(tmp);
}
inline bool odd( int n ){ return n%2; }

vector< complex<double> > fft( vector< complex<double> > a){
  int T = a.size();

  scramble(a);
  
  vector< complex<double> > buf(T);

  for( int i = 0 ; (1<<i) < T ; ++i ){
    int w = (1<<i);
    for( int j = 0 ; j < T/w ; ++j ){
      for( int k = 0 ; k < w ; ++k ){
        int idx = j * w + k;
        if( odd(j) ){
          // a[idx-w] , a[idx]
          buf[idx] = a[idx-w] - omega(k*(T>>(i+1)),T) * a[idx];
        }else{
          // a[idx] , a[idx+w]
          buf[idx] = a[idx] + omega(k*(T>>(i+1)),T) * a[idx+w];
        }
      }
    }
    a = buf;
  }

  return a;
}



int main(){
  ios::sync_with_stdio(false);

  // simple test
  int T = 8;
  vector< complex<double> > a(T,zero);
  for( int i = 0 ; i < T ; ++i ){
    a[i].real( sin((double)i) );
  }
 
  auto f = fft(a);
  cout << "# idft(fft(a))-a" << endl;
  vector< complex<double> > a2 = idft(f);
  for( int i = 0 ; i < T ; ++i ){
    cout << "# " << (a2[i]-a[i]) << endl;
  }

  // time

  struct timeval t_begin,t_end;
  for( int n = 10 ; n <= 20 ; ++n ){
    int T = pow(2,n);
    a.resize(T);
    for( int i = 0 ; i < T ; ++i ){
      a[i].real(sin(T));
      a[i].imag(0.0);
    }
    
    cout << T << endl;
    gettimeofday(&t_begin,NULL);
    f = dft(a);
    gettimeofday(&t_end,NULL);
    cout << " " << (t_end.tv_sec-t_begin.tv_sec)+
    
    gettimeofday(&t_begin,NULL);
    f = fft(a);
    gettimeofday(&t_end,NULL);
  }
  return 0;
}
