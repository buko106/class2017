typedef struct _tnode{
  int val;
  struct _tnode *left,*right;
}tnode;

int btree_is_empty(tnode *t);
tnode *btree_create();
tnode *btree_insert(int v,tnode *t);
void btree_destroy(tnode *t);
void btree_dump(tnode *t);
