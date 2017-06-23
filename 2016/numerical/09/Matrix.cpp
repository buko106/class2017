#ifndef _MY_TEMPLATE_MATRIX_INCLUDE_BODY_
#define _MY_TEMPLATE_MATRIX_INCLUDE_BODY_

#include "Matrix.hpp"
#include <iomanip>
using namespace std;

template<class T> Matrix<T>::Matrix(){
  data.resize(0);
  m_r = 0 ;
  m_c = 0 ;
}

template<class T>  Matrix<T>::Matrix( size_t r ){
  data.resize(r);
  m_r = r;
  m_c = 1;
}

template<class T>  Matrix<T>::Matrix( size_t r , size_t c ){
  data.resize(r*c);
  m_r = r;
  m_c = c;
}

template<class T>  Matrix<T>::Matrix( size_t r , size_t c , const T& init_val ){
  data.resize(r*c);
  for( size_t i = 0 ; i < r*c ; ++i )
    data[i] = init_val;
  m_r = r;
  m_c = c;
}

template<class T> Matrix<T> Matrix<T>::inv( const T& unit ) const {
  if( m_r != m_c ){
    cerr << "size mismatch in Matrix<T>::inv" << endl;
    exit(1);
  }
  LU_Matrix<T> LU = LU_decomposition(*this,unit);
  Matrix<T> one(m_r,m_r,0);
  for( size_t i = 0 ; i < m_r ; ++i ){
    one(i,i) = unit;
  }
  return LU.solve( one );
}

template<class T> Matrix<T> Matrix<T>::trans() const{
  size_t r = m_c;
  size_t c = m_r;
  Matrix<T> B(r,c);
  for( size_t i = 0 ; i < r ; ++i ){
    for( size_t j = 0 ; j < c ; ++j ){
      B(i,j) = data[ j * m_c + i ];
    }
  }
  return B;
}

template<class T> Matrix<T> LU_Matrix<T>::inv( const T& unit ) const{
  Matrix<T> one(n,n,0);
  for( size_t i = 0 ; i < n ; ++i ){
    one(i,i) = unit;
  }
  return solve(one);
}


template<class T> Matrix<T> LU_Matrix<T>::solve( const Matrix<T> &C ) const{// solve A( x1,...,xn ) = ( b1,...,bn ), C is scrambled
  
  if( C.row() != n ){
    cerr << "size mismatch in LU_Matrix<T>::solve" << endl;
    exit(1);    
  }


  Matrix<T> B(C.row(),C.column());
  // swaping
  for( size_t i = 0 ; i < n ; ++i ){
    for( size_t c = 0 ; c < B.column() ; ++c ){
      B(i,c) = C.get(idx[i],c);
    }
  }
  
  // forward
  for( size_t c = 0 ; c < B.column() ; ++c ){
    for( size_t i = 0 ; i < B.row() ; ++i ){
      for( size_t j = 0 ; j < i ; ++j ){
        B(i,c) = B(i,c) - data.get(i,j)*B(j,c) ;
      }
    }
  }

  // backward
  for( size_t c = 0 ; c < B.column() ; ++c ){
    for( int i = n-1 ; i >= 0 ; --i ){
      for( size_t j = i+1 ; j < n ; ++j ){
        B(i,c) = B(i,c) - data.get(i,j)*B(j,c);
      }
      B(i,c) = B(i,c) / data.get(i,i);
    }
  }
  
  return B;
}

template<class T> LU_Matrix<T> LU_decomposition( const Matrix<T> &A , const T& unit ){
  if( A.row() != A.column() ){
    cerr << "square Matrix is expected in LU_decomposition" << endl;
    exit(1);
  }
  size_t n = A.row();
  vector<size_t> idx(n);
  Matrix<T> LU=A;

  for( size_t i = 0 ; i < n ; ++i ){
    idx[i] = i;
  }

  for( size_t i = 0 ; i < n-1 ; ++i ){
    // pivoting
    int pivot_pos = i;
    T pivot_abs = abs(LU(i,i));
    for( size_t j = i+1 ; j < n ; ++j ){
      if( pivot_abs < abs(LU(j,i)) ){
        pivot_pos = j;
        pivot_abs = abs(LU(j,i));
      }
    }
    // swap i , pivot_pos
    swap(idx[i],idx[pivot_pos]);
    for( size_t j = 0 ; j < n ; ++j ){
      swap( LU(i,j) , LU(pivot_pos,j) );
    }
    //
    T tmp = unit / LU(i,i);

    for( size_t j = i+1 ; j < n ; ++j ){
      LU(j,i) = LU(j,i) * tmp;
      for( size_t k = i+1 ; k < n ; ++k ){
        LU(j,k) = LU(j,k) - LU(j,i) * LU(i,k);
      }
    }
  }

  LU_Matrix<T> result;
  result.n = n;
  result.idx = idx;
  result.data = LU;
  return result;
}

template<class T> LU_Matrix<T> Bad_LU_decomposition( const Matrix<T> &A , const T& unit ){
  if( A.row() != A.column() ){
    cerr << "square Matrix is expected in Bad_LU_decomposition" << endl;
    exit(1);
  }
  size_t n = A.row();
  vector<size_t> idx(n);
  Matrix<T> LU=A;

  for( size_t i = 0 ; i < n ; ++i ){
    idx[i] = i;
  }

  for( size_t i = 0 ; i < n-1 ; ++i ){
    // without pivoting
    T tmp = unit / LU(i,i);

    for( size_t j = i+1 ; j < n ; ++j ){
      LU(j,i) = LU(j,i) * tmp;
      for( size_t k = i+1 ; k < n ; ++k ){
        LU(j,k) = LU(j,k) - LU(j,i) * LU(i,k);
      }
    }
  }

  LU_Matrix<T> result;
  result.n = n;
  result.idx = idx;
  result.data = LU;
  return result;
}

template<class T> Matrix<T> LU_Matrix<T>::revert( const T& unit ) const{
  Matrix<T> A(n,n),L(n,n,0),U(n,n,0);
  for( size_t i = 0 ; i < n ; ++i ){
    for( size_t j = 0 ; j < i ; ++j ){
      L(i,j) = data.get(i,j);
    }
    L(i,i) = unit;
  }

  for( size_t i = 0 ; i < n ; ++i ){
    for( size_t j = i ; j < n ; ++j ){
      U(i,j) = data.get(i,j);
    }
  }
  Matrix<T> LU = L*U;
  Matrix<T> ans(LU.row(),LU.column());
  for( int i = 0 ; i < n ; ++i ){
    for( int j = 0 ; j < n ; ++j ){
      ans(idx[i],j) = LU(i,j);
    }
  }
  return ans;
}


template<class T> template <class R> R Matrix<T>::norm() const {
  R sum = 0;
  for( size_t i = 0 ; i < m_r ; ++i ){
    for( size_t j = 0 ; j < m_c ; ++j ){
      R tmp = abs(get(i,j));
      sum = sum + tmp * tmp;
    }
  }

  return sqrt(sum);
}

template<class T> Matrix<T> operator*( const Matrix<T> &A , const Matrix<T> &B ){
  if( A.column() != B.row() || A.column() <= 0 || B.row() <= 0 ){
    cerr << "size mismatch in operator*" << endl;
    exit(1);    
  }
  size_t n = A.column();
  size_t r = A.row();
  size_t c = B.column();
  Matrix<T> C(r,c);
  for( size_t i = 0 ; i < r ; ++i ){
    for( size_t j = 0 ; j < c ; ++j ){
      C(i,j) = A.get(i,0) * B.get(0,j);
      for( size_t k = 1 ; k < n ; ++k ){
        C(i,j) = C(i,j) + A.get(i,k)*B.get(k,j);
      }
    }
  }
  return C;
}

template<class T> Matrix<T> operator*( const T &a , const Matrix<T> &B ){

  size_t r = B.row();
  size_t c = B.column();
  Matrix<T> C(r,c);
  for( size_t i = 0 ; i < r ; ++i ){
    for( size_t j = 0 ; j < c ; ++j ){
      C(i,j) = B.get(i,j) * a ;
    }
  }
  return C;
}

template<class T> Matrix<T> operator*( const Matrix<T> &B , const T &a ){

  size_t r = B.row();
  size_t c = B.column();
  Matrix<T> C(r,c);
  for( size_t i = 0 ; i < r ; ++i ){
    for( size_t j = 0 ; j < c ; ++j ){
      C(i,j) = B.get(i,j) * a ;
    }
  }
  return C;
}

template<class T> Matrix<T> operator/( const Matrix<T> &B , const T &a ){

  size_t r = B.row();
  size_t c = B.column();
  Matrix<T> C(r,c);
  for( size_t i = 0 ; i < r ; ++i ){
    for( size_t j = 0 ; j < c ; ++j ){
      C(i,j) = B.get(i,j) / a ;
    }
  }
  return C;
}

template<class T> Matrix<T> operator+( const Matrix<T> &A , const Matrix<T> &B ){
  if( A.row() != B.row() || A.column() != B.column() ){
    cerr << "size mismatch in operator+" << endl;
    exit(1);    
  }
  size_t r = A.row();
  size_t c = A.column();
  Matrix<T> C(r,c);
  for( size_t i = 0 ; i < r ; ++i ){
    for( size_t j = 0 ; j < c ; ++j ){
      C(i,j) = A.get(i,j) + B.get(i,j);
    }
  }
  return C;
}

template<class T> Matrix<T> operator-( const Matrix<T> &A , const Matrix<T> &B ){
  if( A.row() != B.row() || A.column() != B.column() ){
    cerr << "size mismatch in operator-" << endl;
    exit(1);    
  }
  size_t r = A.row();
  size_t c = A.column();
  Matrix<T> C(r,c);
  for( size_t i = 0 ; i < r ; ++i ){
    for( size_t j = 0 ; j < c ; ++j ){
      C(i,j) = A.get(i,j) - B.get(i,j);
    }
  }
  return C;
}

template<class T> ostream& operator<<(std::ostream& out,Matrix<T> A){
  size_t r = A.row();
  size_t c = A.column();
  for( size_t i = 0 ; i < r ; ++i ){
    if( i ) out << '\n' ;
    for( size_t j = 0 ; j < c ; ++j ){
      out << ' ' << A.get(i,j);
    }
  }
  out << flush;
  return out;
}

#endif
