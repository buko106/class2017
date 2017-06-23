#include<complex>
#include<cmath>
#include<iostream>
using namespace std;

const double pi = acos(-1.0);
const double eps = 1e-15;
const complex<double> z1(cos(   0.0),sin(   0.0));
const complex<double> z2(cos(pi*2/3),sin(pi*2/3));
const complex<double> z3(cos(pi*4/3),sin(pi*4/3));
const complex<double> unit(1.0,0.0);

complex<double> f(complex<double> z){ return z*z*z - unit; }
complex<double> ddfz(complex<double> z) { return 3.0 * z * z ; }

int solve(complex<double> z){
  int count=0 ;
  do{
    z = z - f(z)/ddfz(z) ;
    count ++ ;
  }while( abs(z1-z)>eps && abs(z2-z)>eps && abs(z3-z)>eps );
  return count;
}

int main(){
  int N = 100 ; // 1/N
  for( int x = -N ; x<= N ; ++x ){
    for( int y = -N ; y<= N ; ++y ){
      complex<double> z(1.0*x/N,1.0*y/N);
      cout << z.real() << " " << z.imag() << " " << solve(z) << endl;
    }
  }
  return 0;
}
