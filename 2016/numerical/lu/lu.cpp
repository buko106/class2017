#include<iostream>
#include<iomanip>
#include<cstdlib>
#include<cmath>
#include<vector>
using namespace std;

template<class T> class Matrix;
template<class T> class LU_Matrix;
template<class T> LU_Matrix<T> LU_decomposition( Matrix<T> , T unit=1 );
template<class T> Matrix<T> operator*( Matrix<T> , Matrix<T> );
template<class T> Matrix<T> operator+( Matrix<T> , Matrix<T> );
template<class T> Matrix<T> operator-( Matrix<T> , Matrix<T> );
template<class T> ostream& operator<<( ostream& , Matrix<T> );

template<class T> class Matrix{
private:
  vector<T> data;
  size_t m_r;
  size_t m_c;

public:
  Matrix(){
    data.resize(0);
    m_r = 0;
    m_c = 0;
  }
  Matrix( size_t r , size_t c ){
    data.resize(r*c);
    m_r = r;
    m_c = c;
  }
  Matrix( size_t r , size_t c , const T& init_val ){
    data.resize(r*c);
    for( size_t i = 0 ; i < r*c ; ++i ) data[i] = init_val ;
    m_r = r;
    m_c = c;
  }
  
  inline size_t idx ( size_t r , size_t c ){ return m_c * r + c ; }
  inline T& operator() ( size_t r , size_t c ){ return data[ idx(r,c) ]; }
  inline size_t row() const { return m_r; }
  inline size_t column() const { return m_c; }
  Matrix<T> const inv ( T unit = 1 );
};

template<class T> class LU_Matrix{
private:
  size_t n;
  vector<size_t> idx;
  Matrix<T> data;
public:
  LU_Matrix(){ n = 0 ; idx.resize(0); }
  LU_Matrix( size_t size ){ n = size ; idx.resize(n); }
  LU_Matrix( size_t size , Matrix<T> A ){ n = size ; idx.resize(n) ; data = A; }
  Matrix<T> solve( Matrix<T> B );// solve A( x1,...,xn ) = ( b1,...,bn )
  Matrix<T> const inv( T unit = 1 );
  friend LU_Matrix<T> LU_decomposition<>(Matrix<T> A,T unit);
};

template<class T> LU_Matrix<T> LU_decomposition( Matrix<T> A,T unit ){
  if( A.row() != A.column() ){
    cerr << "square Matrix is expected in LU_decomposition" << endl;
    exit(1);
  }
  size_t n = A.row();
  LU_Matrix<T> LU(n,A);

  for( size_t i = 0 ; i < n ; ++i ){
    LU.idx[i] = i;
  }

  for( size_t i = 0 ; i < n-1 ; ++i ){
    // pivoting
    int pivot_pos = i;
    T pivot_abs = abs(LU.data(i,i));
    for( size_t j = i+1 ; j < n ; ++j ){
      if( pivot_abs < abs(LU.data(j,i)) ){
        pivot_pos = j;
        pivot_abs = abs(LU.data(j,i));
      }
    }
    // swap i , pivot_pos
    swap(LU.idx[i],LU.idx[pivot_pos]);
    for( size_t j = 0 ; j < n ; ++j ){
      swap( LU.data(i,j) , LU.data(pivot_pos,j) );
    }
    //
    T tmp = unit / LU.data(i,i);

    for( size_t j = i+1 ; j < n ; ++j ){
      LU.data(j,i) = LU.data(j,i) * tmp;
      for( size_t k = i+1 ; k < n ; ++k ){
        LU.data(j,k) = LU.data(j,k) - LU.data(j,i) * LU.data(i,k);
      }
    }
  }

  // check
  //
  // cout << "L\\U=\n" << LU.data << endl;
  // Matrix<T> L = LU.data;
  // Matrix<T> U = LU.data;
  // for( int i = 0 ; i < n ; ++i ){
  //   for( int j = 0 ; j < n ; ++j ){
  //     if( i == j ) L(i,j) = 1.0;
  //     if( i < j ) L(i,j) = 0.0;
  //     if( i > j ) U(i,j) = 0.0;
  //   }
  // }
  //  cout << "L*U = \n" << L*U << endl;
  
  return LU;
}

int main(){
  int n = 10;
  Matrix<double> A(n,n);
  // ヒルベルト行列の生成
  for( int i = 0 ; i < n ; ++i ){
    for( int j = 0 ; j < n ; ++j ){
      A(i,j) = 1.0 / (i+j+1);
    }
  }

  // 確認
  cout << "A=\n" << scientific << showpos << setprecision(3) << A << endl;
  
  LU_Matrix<double> LU_A = LU_decomposition(A);
  // Matrix<double> b(n,1);
  // for( int i = 0 ; i < n ; ++i ) b(i,0) = i+1;
  
  // Matrix<double> x  = LU_A.solve(b);
  // cout << "b=\n" << b << endl;
  // cout << "x=\n" << x << endl;
  // cout << "A.inv()*b-x=\n" << A.inv() * b - x<< endl;
  cout << "A * A.inv()=\n" << A * LU_A.inv() << endl;
  // cout << "Ax-b=\n" << A*x-b << endl;
  return 0;
}


template<class T> Matrix<T> const Matrix<T>::inv( T unit ){
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

template<class T> Matrix<T> const LU_Matrix<T>::inv( T unit ){
  Matrix<T> one(n,n,0);
  for( size_t i = 0 ; i < n ; ++i ){
    one(i,i) = unit;
  }
  return this->solve(one);
}

template<class T> Matrix<T> LU_Matrix<T>::solve( Matrix<T> C ){// solve A( x1,...,xn ) = ( b1,...,bn ), C is scrambled
  
  Matrix<T> B(C.row(),C.column());
  
  if( B.row() != n ){
    cerr << "size mismatch in LU_Matrix<T>::solve" << endl;
    exit(1);    
  }

  // swaping
  for( size_t i = 0 ; i < n ; ++i ){
    for( size_t c = 0 ; c < B.column() ; ++c ){
      B(i,c) = C(idx[i],c);
    }
  }
  
  // forward
  for( size_t c = 0 ; c < B.column() ; ++c ){
    for( size_t i = 0 ; i < B.row() ; ++i ){
      for( size_t j = 0 ; j < i ; ++j ){
        B(i,c) = B(i,c) - data(i,j)*B(j,c) ;
      }
    }
  }

  // backward
  for( size_t c = 0 ; c < B.column() ; ++c ){
    for( int i = n-1 ; i >= 0 ; --i ){
      for( size_t j = i+1 ; j < n ; ++j ){
        B(i,c) = B(i,c) - data(i,j)*B(j,c);
      }
      B(i,c) = B(i,c) / data(i,i);
    }
  }
  
  return B;
}

template<class T> Matrix<T> operator*( Matrix<T> A , Matrix<T> B ){
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
      C(i,j) = A(i,0) * B(0,j);
      for( size_t k = 1 ; k < n ; ++k ){
        C(i,j) = C(i,j) + A(i,k)*B(k,j);
      }
    }
  }
  return C;
}

template<class T> Matrix<T> operator+( Matrix<T> A , Matrix<T> B ){
  if( A.row() != B.row() || A.column() != B.column() ){
    cerr << "size mismatch in operator+" << endl;
    exit(1);    
  }
  size_t r = A.row();
  size_t c = A.column();
  Matrix<T> C(r,c);
  for( size_t i = 0 ; i < r ; ++i ){
    for( size_t j = 0 ; j < c ; ++j ){
      C(i,j) = A(i,j) + B(i,j);
    }
  }
  return C;
}

template<class T> Matrix<T> operator-( Matrix<T> A , Matrix<T> B ){
  if( A.row() != B.row() || A.column() != B.column() ){
    cerr << "size mismatch in operator-" << endl;
    exit(1);    
  }
  size_t r = A.row();
  size_t c = A.column();
  Matrix<T> C(r,c);
  for( size_t i = 0 ; i < r ; ++i ){
    for( size_t j = 0 ; j < c ; ++j ){
      C(i,j) = A(i,j) - B(i,j);
    }
  }
  return C;
}

template<class T> ostream& operator<<(std::ostream& out,Matrix<T> A){
  size_t r = A.row();
  size_t c = A.column();
  for( size_t i = 0 ; i < r ; ++i ){
    for( size_t j = 0 ; j < c ; ++j ){
      out << ' ' << A(i,j);
    }
    out << '\n' ;
  }
  out << flush;
  return out;
}
