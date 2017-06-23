#include<mpi.h>
#include<time.h>
#include<stdlib.h>
#include<stdio.h>

#define PROCESS 128
#define EACH 100000
#define neg(a) (1-(a))
const int N =  EACH*PROCESS ;
int buf[2][EACH*PROCESS];
int buf_origin[EACH*PROCESS];

inline int med3(int a,int b,int c){
  if(a<b){
    if(b<c) return b;
    else if(c<a) return a;
    return c;
  }

  // else if(a>=b)
  if(c<b) return b;
  else if(a<c) return a;
  return c;
  
}

void sort(int *left,int *right){
  int n = right - left;// [left,right)
  if(n>=15){
    int* l = left;
    int* r = right-1;
    int pivot = med3(*left,*(left+n/2),*(right-1));
    while(1){
      while( *l < pivot) ++l;
      while( *r > pivot) --r;      
      if( l >= r ) break;
      int temp = *l; *l = *r ; *r = temp; // swap
      ++ l;
      -- r;
    }
    if( l == left ) ++l;
    sort(left,l);
    sort(l,right);
  }else{
    int i;
    for( i=1 ; i<n ; ++i){
      int temp = left[i];
      if(left[i-1] > temp){
        int j = i;
        do{
          left[j] = left[j-1];
          --j;
        }while( j>0 && left[j-1] > temp);
        left[j] = temp;
      }
    }
  }
  return ;
}

void merge( int *dest , int *s , int ns , int *t , int nt ){
  int is=0,it=0;
  while( is<ns || it<nt ){
    if( it>=nt ||  (is<ns && s[is]<t[it])){
      dest[is+it] = s[is];
      ++ is;
    }else{
      dest[is+it] = t[it];
      ++ it;
    }
  }
  return ;
}

void debug_print( int *p , int n ){
  int i;
  for( i=0 ; i<n ; ++i )
    printf("%10d = [%d]\n",p[i],i);
  return ;
}

int main(int argc,char **argv){
  int rank,numproc,i;
  double t_begin,t_end;
  MPI_Init(&argc,&argv);
  MPI_Comm_size(MPI_COMM_WORLD, &numproc);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  // printf(" numproc = %d , rank = %d\n",numproc,rank);
  srand(time(NULL));
  MPI_Barrier(MPI_COMM_WORLD);
  if( rank == 0 ){
    for( i=0 ; i < N ; ++i){
      buf[0][i] = rand();
    }
    memcpy(buf_origin,buf[0],N*sizeof(int));
    for( i=1 ; i < PROCESS ; ++i){
      MPI_Send(buf[0]+(i*EACH) , EACH , MPI_INT , i , 0 , MPI_COMM_WORLD);
    }
  }else{
    MPI_Recv(buf[0], EACH , MPI_INT , 0 , 0 , MPI_COMM_WORLD , NULL );
  }

  MPI_Barrier(MPI_COMM_WORLD);
  t_begin = MPI_Wtime();
  // start
  
  sort(buf[0],buf[0]+EACH);
  //double t_sort = MPI_Wtime();
  int w,select=0,tag=0;

  for( w=1 ; w<PROCESS ; w*=2 ){ // merging
    if( rank%(2*w) == w ){
      MPI_Send( buf[select] , w*EACH , MPI_INT , rank-w , tag , MPI_COMM_WORLD );
      break;
    }else{
      MPI_Recv( buf[select] + w*EACH , w*EACH , MPI_INT , rank+w , tag , MPI_COMM_WORLD , NULL);
      //double before_merge,after_merge;
      //before_merge = MPI_Wtime();
      merge( buf[neg(select)] , buf[select] , w*EACH , buf[select]+w*EACH , w*EACH);
      //after_merge = MPI_Wtime();
      //printf("merge time = %lf\n" , after_merge - before_merge );
    }
    select = neg(select);
  }


  if( rank == 0 ){ // send back to rank 1~PROCESS
    for( i=1 ; i < PROCESS ; ++i){
      MPI_Send(buf[select]+(i*EACH) , EACH , MPI_INT , i , 0 , MPI_COMM_WORLD);
    }
  }else{
    MPI_Recv(buf[0], EACH , MPI_INT , 0 , 0 , MPI_COMM_WORLD , NULL );
  }

  // end
  MPI_Barrier(MPI_COMM_WORLD);
  t_end = MPI_Wtime();
  
  // if(rank==0) { debug_print( buf[select] , N ); debug_print(buf_origin , N ); }

  if(rank==0){
    //printf("N=%d , time = %lf(sec) , sort time = %lf\n", N ,t_end-t_begin,t_sort-t_begin);
    printf("N=%d , time = %lf(sec)\n", N ,t_end-t_begin);

    sort(buf_origin,buf_origin+N);
 
    //debug_print( buf[select] , N );
    //debug_print( buf_origin , N ) ;
    int correct = 1;
    for( i=0 ; i<N ; ++i ) if( buf[select][i] != buf_origin[i] ) correct = 0;
    printf("result = %s\n" , (correct? "OK" : "NG" ));
  }
  MPI_Finalize();
  return 0;
}
