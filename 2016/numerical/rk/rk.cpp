#include<iostream>
#include<cmath>

using namespace std;

const double pi = acos(-1.0);

class var{
public:
  double y,g;

  var operator+(const var& arg){
    var ret = { y  +  arg.y ,
                g  +  arg.g };
    return ret ;
  }
  var operator*(const double& arg){
    var ret = { y * arg , g * arg };
    return ret ; 
  }
  var f(double x){
    var ret = { g , cos(x)-2*y-3*g } ;
    return ret ;
  }
  double norm(){ return sqrt(y*y+g*g); }
};

double answer(double x){ return -0.5*exp(-x) + 0.4*exp(-2.*x) + 0.3*sin(x) + 0.1*cos(x); }

int main(){
  ios::sync_with_stdio(false);
  double a[10][10]={};
  double b4[10]={},b5[10]={};
  double c[10]={};
  
  c[1]=0.;
  c[2]=1./4.  ; a[2][1]=1./4.      ;
  c[3]=3./8.  ; a[3][1]=3./32.     ; a[3][2]=9./32.      ;
  c[4]=12./13.; a[4][1]=1932./2197.; a[4][2]=-7200./2197.; a[4][3]=7296./2197;
  c[5]=1.     ; a[5][1]=439./216.  ; a[5][2]=-8.         ; a[5][3]=3680./513.   ; a[5][4]=-854./4104.;
  c[6]=1./2.  ; a[6][1]=-8./27.    ; a[6][2]=2.          ; a[6][3]=-3544./2565. ; a[6][4]=1859./4104.; a[6][5]=-11./40.;
  b5[1]=16./135. ; b5[2]=0. ; b5[3]=6656./12825. ; b5[4]=28561./56430. ; b5[5]=-9./50. ; b5[6]=2./55.;
  b4[1]=25./216. ; b4[2]=0. ; b4[3]=1408./2565.  ; b4[4]=2197./4104.;  ; b4[5]=-1./5.;

  int iter=0;
  const double eps = 1E-15;
  double h = 1.0E-6;
  double x = 0.;
  var y = { 0. , 0. };
  while( x <= 2.*pi ){
    iter++;
    
    while(true){
      var fk[10];
      for( int i = 1 ; i <= 6 ; ++i ){
        // fk[i]
        var dy={0.,0.};
        for( int j = 1 ; j <= i-1 ; ++j ){
          dy = dy + fk[j]*a[i][j];
        }
        dy = dy*h;
        
        fk[i]=(y+dy).f(x+h*c[i]);
      }
      // yk -> yk+1
      var dy5={0.,0.};
      for( int i = 1 ; i <= 6; ++i ){
        dy5 = dy5 + fk[i]*b5[i];
      }
      dy5 = dy5*h;
      //
      var dy4={0.,0.};
      for( int i = 1 ; i <= 6; ++i ){
        dy4 = dy4 + fk[i]*b4[i];
      }
      dy4 = dy4*h;
      //
      double T= (dy5*(-1.0)+dy4).norm();
      if( T < eps ){
            x += h;
            y = y + dy5;
            // update h
            h = 0.5 * h * pow(eps/T,1.0/5.0);
            break;
      }else{
        h = 0.5 * h;
      }
    }
    
    if(iter%10 == 0) cout << x << " " << y.y-answer(x) << " " << h << endl;
  }

  return 0;
}
