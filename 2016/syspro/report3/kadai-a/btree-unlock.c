#include "btree.h"
#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>

pthread_mutex_t m = PTHREAD_MUTEX_INITIALIZER;

inline int btree_is_empty(tnode *t){
  return t==NULL;
}

inline tnode *btree_create(){
  return NULL;
}

tnode *btree_insert(int v,tnode *t){

  if(btree_is_empty(t)){

    t = malloc(sizeof(tnode));
    t -> val = v;
    t -> left = btree_create();
    t -> right= btree_create();

    return t;
  }

  if(v<=t->val){
    t -> left = btree_insert(v,t->left);
  }
  else
    t -> right= btree_insert(v,t->right);
  return t;
}

void btree_destroy(tnode *t){
  if(btree_is_empty(t))return;
  btree_destroy(t->left);
  btree_destroy(t->right);
  free(t);
}

void btree_dump(tnode *t){
  if(btree_is_empty(t))return;
  btree_dump(t->left);
  printf("%d\n",t->val);
  btree_dump(t->right);
  return;
}

void *func(void *p){
  int i;
  tnode **t = p;
  for(i=0;i<10;++i){
    //pthread_mutex_lock(&m);
    *t = btree_insert(i,*t);
    //pthread_mutex_unlock(&m);
  }
  return NULL;
}

#define NUM 10

int main(){
  tnode *root=btree_create();
  pthread_t thread[NUM];
  int i;
  for(i=0;i<NUM;++i){
    if(pthread_create(&thread[i],NULL,func,&root)!=0){
      printf("error: pthread_create\n");
      return 1;
    }
  }
  for(i=0;i<NUM;++i){
    if(pthread_join(thread[i],NULL)!=0){
      printf("error: pthread_join\n");
      return 1;
    }
  }
  btree_dump(root);
  return 0;
}
