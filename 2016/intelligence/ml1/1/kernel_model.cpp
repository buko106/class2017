#include <iostream>
#include <Eigen/Core>
#include <Eigen/LU>
#include <random>

using namespace std;;
using namespace Eigen;

const double pi=acos(-1.0);

double diff(VectorXd x,VectorXd y,VectorXd X,VectorXd Y,int n,int N,double h,double l){
  double hh=2.0*h*h;
  MatrixXd k(n,n);
  for( int i = 0 ; i < n ; ++i )
    for( int j = 0 ; j < n ; ++j )
      k(i,j)=exp(-(x(i)*x(i)-2*x(i)*x(j)+x(j)*x(j))/hh);
  
  //VectorXd t(n); t = (k*k+l*MatrixXd::Identity(n,n)).inverse() * (k*y);
  VectorXd t = (k*k+l*MatrixXd::Identity(n,n)).fullPivLu().solve(k*y);

  MatrixXd K(N,n);
  for( int i = 0 ; i < N ; ++i )
    for( int j = 0 ; j < n ; ++j )
      K(i,j)=exp(-(X(i)*X(i)-2*X(i)*x(j)+x(j)*x(j))/hh);
  VectorXd F(N); F = K*t;
  
  double sum=0.0;
  for( int i = 0 ; i < N ; ++i )
    sum += abs(Y(i)-F(i));
  
  return sum/N;
}

double eval(VectorXd x,VectorXd y,int npg,int group,double h,double l){
  VectorXd sample(npg*(group-1));
  VectorXd answer(npg*(group-1));
  VectorXd X(npg);
  VectorXd Y(npg);

  double sum=0.0;
  for( int i=0 ; i<group ; ++i ){
    int count_s=0;
    for( int j = 0 ; j<group ; ++j ){
      for( int k = 0 ; k<npg ; ++k){
        if( i==j ){
          X(k)=x(k+j*npg);
          Y(k)=y(k+j*npg);
        }else{
          sample(count_s)=x(k+j*npg);
          answer(count_s)=y(k+j*npg);
          count_s++;
        }
      }
    }
    sum += diff(sample,answer,X,Y,npg*(group-1),npg,h,l);
  }
  return sum/group;
}

pair<double,double> solve(VectorXd x,VectorXd y,int npg,int group){
  pair<double,double> hl;
  double mx=1.0e20;
  for( int L = 1 ; L <= 20 ; ++L )
    for( int H = 1 ; H <= 20 ; ++H ){
      double l=L/100.0;
      double h=H/20.0;
      double res = eval(x,y,npg,group,h,l);
      if( res < mx ){
        mx = res;
        hl = make_pair(h,l);
      }
    }
  return hl;
}

int main(){
  std::ios::sync_with_stdio(false);

  random_device rd;
  mt19937 mt;
  normal_distribution<double> norm(0.0,1.0);
  mt.seed(rd());

  int npg=5,group=10;
  int n=npg*group;
  int N=1000;
  VectorXd x = VectorXd::LinSpaced(n,-3.0,3.0);
  VectorXd X = VectorXd::LinSpaced(N,-3.0,3.0);
  VectorXd pix= pi*x;
  VectorXd y(n);
  for( int i = 0 ; i < n ; ++i ) y(i)=sin(pix(i))/pix(i)+0.1*x(i)+0.2*norm(mt);

  // double h=0.1,l=0.1; // temporally
  pair<double,double> result = solve(x,y,npg,group);
  double h = result.first;
  double l = result.second;

  double hh=2.0*h*h;
  MatrixXd k(n,n);
  for( int i = 0 ; i < n ; ++i )
    for( int j = 0 ; j < n ; ++j )
      k(i,j)=exp(-(x(i)*x(i)-2*x(i)*x(j)+x(j)*x(j))/hh);

  //VectorXd t(n); t = (k*k+l*MatrixXd::Identity(n,n)).inverse() * (k*y);
  VectorXd t = (k*k+l*MatrixXd::Identity(n,n)).fullPivLu().solve(k*y);
  MatrixXd K(N,n);
  for( int i = 0 ; i < N ; ++i )
    for( int j = 0 ; j < n ; ++j )
      K(i,j)=exp(-(X(i)*X(i)-2*X(i)*x(j)+x(j)*x(j))/hh);
  VectorXd F(N); F = K*t;
  
  MatrixXd XF(N,2); XF << X,F;
  cout << XF << endl;
  cout << "# h= " << h << endl;
  cout << "# l= " << l << endl;
  return 0;
}
