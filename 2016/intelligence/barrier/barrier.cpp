#include <iostream>
#include <cmath>
using namespace std;

class var{
public:
  double x,y;
  double f(void){ return 3.0*x*x + 2.0*y*y ; }
  double g(double c){ return 3.0*x*x + 2.0*y*y - c*log(x+y-1.0) ;}
  double abs2(void){ return x*x + y*y ; }
  var Dg(double c){
    var ret;
    ret.x = 6.0*x - c/(x+y-1.0);
    ret.y = 4.0*y - c/(x+y-1.0);
    return ret;
  }
  var operator*(double a){
    var ret;
    ret.x = a*x;
    ret.y = a*y;
    return ret;
  }
  var operator+(const var &arg){
    var ret;
    ret.x = x + arg.x;
    ret.y = y + arg.y;
    return ret;
  }
  var operator-(const var &arg){
    var ret;
    ret.x = x - arg.x;
    ret.y = y - arg.y;
    return ret;
  }
};

var barrier(double c,var initx){
  // minimize g() with backtrack
  const double alpha=0.5,beta=0.5;
  var x = { 0.0 , 0.0 }; // tekitou de OK, (1,1) is NG.
  var nx = initx; 
  while( (nx-x).abs2() > 1.0e-25 ){
    double eps = 1.0;
    x = nx;
    
    while((x-x.Dg(c)*eps).x+(x-x.Dg(c)*eps).y-1.0 <= 0.0
          || (x - x.Dg(c)*eps).g(c) - x.g(c) 
           > x.Dg(c).abs2() * (-alpha * eps) )
      eps *= beta ;
    nx = x - x.Dg(c)*eps;
  }
  return nx;
  
}

int main(){
  double c = 0.1;
  var x = { 0.0 , 0.0 }; // tekitou de OK, (1,1) is NG.
  var nx= { 10.0 , 10.0 };
  while( (nx-x).abs2() > 1.0e-25 ){
    x = nx;
    nx = barrier(c,x);
    c *= 0.5;
    cout << nx.x << " " << nx.y << endl;
  }
  return 0;
}
