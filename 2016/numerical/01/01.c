#include<stdio.h>
#include<math.h>

inline double square(double x){return x*x;}

int main(){
  double r;
  double x1,y1,vx1,vy1;
  double x2,y2,vx2,vy2;
  double x ,y ,vx ,vy ; // relative value
  double a,b,c;
  //input
  printf("radius:");
  scanf("%lf",&r);

  printf("x1 y1 vx1 vy1:");
  scanf("%lf %lf %lf %lf",&x1,&y1,&vx1,&vy1);

  printf("x2 y2 vx2 vy2:");
  scanf("%lf %lf %lf %lf",&x2,&y2,&vx2,&vy2);
  // relative value
  x  =  x2 -  x1;
  y  =  y2 -  y1;
  vx = vx2 - vx1;
  vy = vy2 - vy1;
  // set equation
  a = square(vx) + square(vy);
  b = 2 * ( x * vx + y * vy) ;
  c = square(x) + square(y) - 4 * square(r) ;

  // solve
  double D = square(b) - 4 * a * c;
  double t1,t2;
  if( D < 0 ){
    printf("no collision\n");
  }else{
    // b > 0 then t1 = (-b - sqrt(D))/ 2a and t2 = c/a/t1
    // b <=0 then t2 = (-b + sqrt(D))/ 2a and t1 = c/a/t2
    if( b>0 ){
      t1 = (-b - sqrt(D))/(2*a) ;
      t2 = c / a / t1;
    }else{
      t2 = (-b + sqrt(D))/(2*a) ;
      t1 = c / a / t2;
    }
    printf("collision at t = %lf\n",t1);
  }
  return 0;
}
