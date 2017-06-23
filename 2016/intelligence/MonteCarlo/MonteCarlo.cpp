#include<random>
#include<iostream>
#include<iomanip>
using namespace std;

int main(){
  random_device rd;
  mt19937 mt(rd());
  uniform_real_distribution<double> ud(-1.0,1.0);

  int output=10;
  int inside=0;
  for( int i=1 ; i <= 1000000000 ; ++i ){
    double x = ud(mt);
    double y = ud(mt);
    if( x*x + y*y <= 1.0 )
      ++inside;

    if( i == output ){
      cout << "pi=" << setprecision(15) << 4.0*inside/i << " (iteration=" << i << ")" << endl;
      output *= 10;
    }
  }
    
  return 0;
}
