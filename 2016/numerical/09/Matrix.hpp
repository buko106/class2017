#ifndef _MY_TEMPLATE_MATRIX_INCLUDE_HEADER_
#define _MY_TEMPLATE_MATRIX_INCLUDE_HEADER_

#include<iostream>
#include<cstdlib>
#include<cmath>
#include<vector>
using namespace std;

template<class T> class Matrix;
template<class T> class LU_Matrix;
template<class T> LU_Matrix<T> LU_decomposition( const Matrix<T>& , const T& unit=1 );
template<class T> LU_Matrix<T> Bad_LU_decomposition( const Matrix<T>& , const T& unit=1 );
template<class T> Matrix<T> operator*( const Matrix<T>& , const Matrix<T>& );
template<class T> Matrix<T> operator*( const T& , const Matrix<T>& );
template<class T> Matrix<T> operator*( const Matrix<T>& , const T& );
template<class T> Matrix<T> operator/( const Matrix<T>& , const T& );
template<class T> Matrix<T> operator+( const Matrix<T>& , const Matrix<T>& );
template<class T> Matrix<T> operator-( const Matrix<T>& , const Matrix<T>& );
template<class T> ostream& operator<<( const ostream& , const Matrix<T>& );

template<class T> class Matrix{
private:
  vector<T> data;
  size_t m_r;
  size_t m_c;

public:
  // constructor
  Matrix();
  Matrix( size_t );// Vector
  Matrix( size_t , size_t );
  Matrix( size_t , size_t , const T& );
  // member function
  inline size_t idx( size_t r , size_t c ) const { return m_c * r + c ; }
  inline T& operator()( size_t r ){ return data[ r ]; }// Vector
  inline T& operator()( size_t r , size_t c ){ return data[ idx(r,c) ]; }
  inline const T& get( size_t r ) const { return data[ r ]; }// Vector
  inline const T& get( size_t r , size_t c ) const { return data[ idx(r,c) ]; }
  inline size_t row() const { return m_r; }
  inline size_t column() const { return m_c; }
  Matrix<T> inv ( const T& unit = 1 ) const;
  Matrix<T> trans() const;
  template<class R = double> R norm() const;
};

template<class T> class LU_Matrix{
private:
  size_t n;
  vector<size_t> idx;
  Matrix<T> data;
public:
  // default constructor
  LU_Matrix(){ n = 0 ; idx.resize(0); }
  // member function
  Matrix<T> solve( const Matrix<T>& ) const;// solve A( x1,...,xn ) = ( b1,...,bn )
  Matrix<T> inv( const T& unit = 1 ) const;
  friend LU_Matrix<T> LU_decomposition<>( const Matrix<T>& , const T& );
  friend LU_Matrix<T> Bad_LU_decomposition<>( const Matrix<T>& , const T& );
  Matrix<T> revert( const T& unit = 1 ) const;
};

#include"Matrix.cpp"

#endif
