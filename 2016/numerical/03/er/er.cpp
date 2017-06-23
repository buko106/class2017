#include<iostream>
#include<cmath>

using namespace std;
const unsigned ITERATION = 10000000;
class var{
public:
  double x,y,vx,vy;

  var operator+(const var& arg){
    var ret = { x  +  arg.x ,
                y  +  arg.y ,
                vx +  arg.vx ,
                vy +  arg.vy };
    return ret ;
  }
  var operator*(const double& arg){
    var ret = { x * arg , y * arg , vx * arg , vy * arg };
    return ret ; 
  }
   var f(const double G,const double m1,const double m2){
    double r2 = x*x + y*y ;
    var ret = { vx , vy ,
                -G * (m1+m2) * x * pow(r2,-1.5),
                -G * (m1+m2) * y * pow(r2,-1.5) } ;
    return ret ;
  }
};

int main(){
  ios::sync_with_stdio(false);
  double h;
  unsigned n;
  // get object data
  double m = 1.0,G = 1.0 ; // templorally
  var planet ;
  double M ; 
  cin >> M ;
  //  cin >> planet.x >> planet.y >> planet.vx >> planet.vy ;
  planet.x = 10 ; planet.y = 0 ; planet.vx = 0 ;
  cin >> planet.vy ;
  
  var pInit = planet;
  for( n = 800 ; n <=102400 ; n*= 2){
    h = 1.0 / (double) n;
    planet = pInit ;
    
    for( unsigned i = 0 ; i < ITERATION ; ++ i ){
      // cout << i << " " 
      //      << planet.x << " "
      //      << planet.y << " " 
      //      << planet.vx << " " 
      //      << planet.vy << endl;

      var p,k1,k2,k3,k4;
      p  = planet;
      k1 = p.f(G,m,M);
      p  = planet + k1*(h*0.5);
      k2 = p.f(G,m,M);
      p  = planet + k2*(h*0.5);
      k3 = p.f(G,m,M);
      p  = planet + k3*h;
      k4 = p.f(G,m,M);
      var next_planet = planet + (k1+k2*2.0+k3*2.0+k4)*(h/6.0) ;
      if( i>0 && next_planet.y > 0.0 && planet.y <= 0.0){
        cout << h << " "
             << abs(pInit.x  - planet.x) << " "
             << abs(pInit.y  - planet.y) << " "
             << abs(pInit.vx - planet.vx) << " "
             << abs(pInit.vy - planet.vy) << " "
             << endl;
        break;
      }
      planet  = next_planet ;
    }
  }
  return 0;
}
