#include<cmath>
#include<iostream>
#include<iomanip>
using namespace std;

const double pi = acos(-1.0);
const double eps= pow(2.0,-52);

double phi(double t){
  return tanh((pi/2.0)*sinh(t));
}

double one_plus_phi(double t){
  if(t>=0.0)
    return 1.0+phi(t);

  double u = (pi/2.0)*sinh(t);
  return exp(u)/cosh(u);
}
double one_minus_phi(double t){
  if(t<=0.0)
    return 1.0-phi(t);
  
  double u = (pi/2.0)*sinh(t);
  return exp(-u)/cosh(u);
}

double F(double t){
  return pi*cosh(t)/(cosh(pi*sinh(t))+1.0)
    /sqrt(one_minus_phi(t)*one_plus_phi(t));
}

double J(double h){
  // get I ( aprox )
  double I = 0.1*F(0.0);
  for( double t = 0.1 ; t <= 3.00001 ; t+=0.1 ){
    I += h*F(t);
    I += h*F(-t);
  }
  
  // get J
  double result = h*F(0.0);
  for( double t = h ; true ; t+=h ){
    double f = F(t);
    if( f < eps * I ) break;
    result += f*h;
  }
  
  for( double t = h ; true ; t+=h ){
    double f = F(-t);
    if( f < eps * I ) break;
    result += f*h;
  }
  
  return result;
}

int main(){
  ios::sync_with_stdio(false);
  //

  double I = J(0.01);
  for( double h = 1.0 ; true ; h /= 1.01 ){
    double Jh=J(h);
    double Jh2=J(h/2.0);
    double diff = abs(Jh-Jh2);
    
    if( diff < abs(I * eps ) )
      break;

    cout << setprecision(15) << h << " " <<  Jh << " " << Jh2 << " " << diff << endl;
  }
  
  //
  return 0;
}
