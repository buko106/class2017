
typedef struct _sudoku{
  int masu[81];
} sudoku;

typedef struct _sudoku_answer{
  int masu[81];
  int unique;
} sudoku_answer;

sudoku_answer solver(sudoku);
int to_column(int n);
int to_row   (int n);
int to_block (int n);
