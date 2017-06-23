#include<iostream>
#include<cmath>
using namespace std;

double r;
double u0;

inline double sq(double x){ return x*x; }

inline double f(double u){
  return cos(u) + pow( sq(r)-sq(u-u0) , 1.0/2.0);
}

inline double f1(double u){
  return -sin(u) - 2.0*(u-u0)*pow( sq(r)-sq(u-u0) , -1.0/2.0);
}

inline double f2(double u){
  return -cos(u) - 2.0*sq(r)*pow( sq(r)-sq(u-u0) , -3.0/2.0);
}


int main(){
  ios::sync_with_stdio(false);
  double x0,y0,z0;
  const double g = 9.80665;
  
  cout << "r x0 y0 z0:" << flush;
  cin >> r;
  cin >> x0;
  cin >> y0;
  cin >> z0;
  
  u0 = sqrt(sq(x0)+sq(y0));
  int iter=0;
  double u = u0;
  while(abs(f1(u))>=1.0E-10){
    u = u - f1(u)/f2(u);
    ++iter;
  }

  double z1 = f(u);
  double t = sqrt(2*(z0-z1)/g);
  cout << "iteration=" << iter << endl;
  cout << "u=" << u << endl;
  cout << "collision at (x,y,z)=(" 
       << (u0==0.0?0.0:x0*u/u0) << ","
       << (u0==0.0?0.0:y0*u/u0) << ","
       << cos(u) << ")" << endl;
  cout << "t=" << t << endl;
  
  return 0;
}
