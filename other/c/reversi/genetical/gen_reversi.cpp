#include <iostream>
#include <iomanip>
#include <vector>
#include <string>
#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <cstring>
#include <cctype>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/ip.h>
#include <netdb.h>
using namespace std;

//functions in play.cpp
uint64_t genetic_play( vector<uint8_t> ,uint64_t , uint64_t);
uint64_t get_rev( uint64_t , uint64_t, uint64_t);
uint64_t valid_moves( const uint64_t, const uint64_t);
//end
const int EMPTY = 0;
const int BLACK = 1;
const int WHITE = 2;
const int WALL  = 3;

const int dx[] = { -10, -9, -8, -1, 1, 8, 9, 10 };

int board[10 + 8 * 9 + 9];

int mycolor;
int rem_time;
bool bgwhite = false;
bool hint = true;
string name = "buko106", opp_name;
vector<uint8_t> genome =
  {58,181,79,167,22,53,88,163,195,26,
180,87,252,163,178,27,159,91,176,225,
112,57,181,126,182,84,214,40,215,90,
102,243,83,208,199,5,131,242,229,147,
239,108,15,182,244,42,119,3,145,58,
168,146,97,192,45,45,228,214,117,20,
134,142,145,169,6,247,127,236,117,229,
18,160,177,152,186,98,32,197,75,66,
81,185,235,71,170,100,32,105,216,146,
249,40,200,77,192,115,68,70,8,233,
242,196,11,137,215,95,45,165,110,246,
32,171,219,110,151,118,164,100,233,183,
67,196,106,162,32,250,100,39,180,216,
162,235,215,211,209,133,231,204,142,181,
152,123,51,49,44,152,7,129,92,158,
   119,249,117,123,7,120,249,147,96,54};



int lastx, lasty, turn = BLACK, turn_count;
string kifu[2];

int opp_color(int c) { return 3 - c; }
int idx(int x, int y) { return 10 + 9 * y + x; }


pair<uint64_t,uint64_t> board_to_othello_board(int c){
  uint64_t player = 0x0ull;  /* turn of c */
  uint64_t opponent=0x0ull;
  
  for( int i = 0 ; i < 8 ; ++i ){
    for( int j = 0 ; j < 8 ; ++j ){
      player <<= 1;
      opponent <<= 1;
      if( board[idx(j,i)] == c )
        player |= 0x1ull ;
      else if( board[idx(j,i)] == opp_color(c) )
        opponent|= 0x1ull;
    }
  }
  return make_pair(player,opponent);
}

void update_board_from_othello_board(pair<uint64_t,uint64_t> ob){
  uint64_t player  = ob.first;
  uint64_t opponent= ob.second;
  for( int i = 0 ; i < 10 + 8 * 9 + 9 ; ++i ){
    board[i] = WALL;
  }

  for( int i = 0 ; i < 8 ; ++i ){
    for( int j = 0 ; j < 8 ; ++j ){
      if( 0x1ull & (player>>(63-(i+8*j))) )
        board[idx(i,j)] = turn;
      else if( 0x1ull&(opponent>>(63-(i+8*j))) )
        board[idx(i,j)] = opp_color(turn);
      else
        board[idx(i,j)] = EMPTY;
    }
  }
  return;
}

string to_str(int x, int y)
{
    const char *t = "abcdefgh", *s = "12345678";
    return string(1, t[x]) + string(1, s[y]);
}

string pos_to_str( uint64_t pos ){
  string ret = "00";
  for( int i = 0 ; i < 8 ; ++i ){
    for( int j = 0 ; j < 8 ; ++j ){
      if( (0x8000000000000000ull >> (i+8*j)) & pos )
        ret = to_str(i,j);
    }
  }
  return ret;
}

pair<int, int> to_pair(string str)
{
    if (str.size() != 2) return make_pair(-1, -1);
    int x = tolower(str[0]) - 'a';
    int y = str[1] - '1';
    if (0 <= x && x < 8 && 0 <= y && y < 8) return make_pair(x, y);
    return make_pair(-1, -1);
}

bool is_valid(int x, int y, int c)
{
    // if (board[idx(x, y)] != EMPTY) return false;
    // for (int i = 0; i < 8; ++i) {
    //     if (board[idx(x, y) + dx[i]] == opp_color(c)) {
    //         for (int j = 2; ; ++j) {
    //             if (board[idx(x, y) + j * dx[i]] == c) return true;
    //             if (board[idx(x, y) + j * dx[i]] != opp_color(c)) break;
    //         }
    //     }
    // }
    // return false;
  pair<uint64_t,uint64_t> ob = board_to_othello_board(c);
  return 0x0ull != (valid_moves(ob.first,ob.second) & (0x1ull<<(63-(x+8*y)))); 
}

bool force_pass(int c)
{
    for (int i = 0; i < 8; ++i)
        for (int j = 0; j < 8; ++j)
            if (is_valid(i, j, c))
                return false;
    return true;
}

void move(int x, int y)
{
    lastx = x;
    lasty = y;
    // board[idx(x, y)] = turn;
    // for (int i = 0; i < 8; ++i) {
    //     for (int j = 1; ; ++j) {
    //         if (board[idx(x, y) + j * dx[i]] == turn)
    //             for (int k = 1; k < j; ++k)
    //                 board[idx(x, y) + k * dx[i]] = turn;
    //         if (board[idx(x, y) + j * dx[i]] != opp_color(turn))
    //             break;
    //     }
    // }
    pair<uint64_t,uint64_t> ob = board_to_othello_board(turn);
    uint64_t mv = 0x1ull << (63-(x+8*y));
    uint64_t rev= get_rev(ob.first,ob.second,mv);
    update_board_from_othello_board(make_pair(ob.first^(rev|mv),ob.second^rev));
    kifu[turn_count >= 30] += to_str(x, y);
    ++turn_count;
    turn = opp_color(turn);
}

void pass()
{
    turn = opp_color(turn);
    if (!force_pass(turn))
        kifu[turn_count >= 30] += "-";
}

const char* cir(int t)
{
    if (t == BLACK) return bgwhite ? "● " : "○ ";
    return bgwhite ? "○ " : "● ";
}

void print(bool first)
{
    cout << (first ? "\n" : "\r\x1b[22A");
    cout << "     a  b  c  d  e  f  g  h"   << endl;
    cout << "   ┌──┬──┬──┬──┬──┬──┬──┬──┐" << endl;
    for (int i = 0; i < 8; ++i) {
        if (i) cout << "   ├──┼──┼──┼──┼──┼──┼──┼──┤";
        switch (i) {
            case 0:  break;
            case 2:  cout << "      " << cir(WHITE) << ": " << (mycolor == WHITE ? name + " (自分)" : opp_name) << endl; break;
            case 5:  cout << "      持ち時間: " << rem_time << "秒" << endl; break;
            default: cout << endl; break;
        }
        cout << " " << i + 1 << " │";
        for (int j = 0; j < 8; ++j) {
            if (j) cout << "│";
            if (i == lasty && j == lastx) cout << "\x1b[46m";
            switch (board[idx(j, i)]) {
                case BLACK:
                    cout << cir(BLACK); break;
                case WHITE:
                    cout << cir(WHITE); break;
                case EMPTY:
                    cout << ((hint && is_valid(j, i, turn)) ? "\x1b[34m✕ \x1b[39m" : "  "); break;
            }
            if (i == lasty && j == lastx) cout << "\x1b[49m";
        }
        cout << "│";
        switch (i) {
            case 1:  cout << "      " << cir(BLACK) << ": " << (mycolor == BLACK ? name + " (自分)" : opp_name) << endl; break;
            case 3:
                cout << "      " << cir(BLACK) << " " << setw(2) << left << count(board, board + 91, BLACK);
                cout << "   "    << cir(WHITE) << " " << setw(2) << left << count(board, board + 91, WHITE) << endl;
                break;
            default: cout << endl; break;
        }
    }
    cout << "   └──┴──┴──┴──┴──┴──┴──┴──┘" << endl;
    cout << endl;
    cout << kifu[0] << endl;
    cout << kifu[1] << endl;
    cout << endl;
    cout << "          " << endl;
    if (turn == mycolor) cout << "あなたの手番です。        ";
    else                 cout << "対戦相手を待っています... ";
    cout << "\r\x1b[A> " << flush;
}

void init_board()
{
    for (int i = 0; i < 10; ++i) board[i] = WALL;
    for (int i = 0; i < 8; ++i) {
        for (int j = 0; j < 9; ++j) {
            if ((i == 3 && j == 4) || (i == 4 && j == 3)) {
                board[idx(j, i)] = BLACK;
            } else if ((i == 3 && j == 3) || (i == 4 && j == 4)) {
                board[idx(j, i)] = WHITE;
            } else if (j == 9) {
                board[idx(j, i)] = WALL;
            } else {
                board[idx(j, i)] = EMPTY;
            }
        }
    }
    for (int i = 0; i < 9; ++i) board[10 + 8 * 9 + i] = WALL;
    lastx = lasty = -1;
    turn = BLACK;
    turn_count = 0;
    kifu[0].clear();
    kifu[1].clear();
}


void show_help(char *prog)
{
    cerr << "使用法: " << prog << " [オプション]" << endl;
    cerr << "  -H HOST   サーバーのホスト名を指定" << endl;
    cerr << "  -p PORT   サーバーのポート番号を指定" << endl;
    cerr << "  -n NAME   プレイヤー名を指定" << endl;
    cerr << "  -c        黒と白の表示を反転する" << endl;
    cerr << "  -x        合法手を表示しない" << endl;
    cerr << "  -h, -?    ヘルプを表示" << endl;
    exit(1);
}

int send(int sock, string str)
{
    return write(sock, str.c_str(), str.size());
}

int recv(int sock, string &str)
{
    static string prev;
    string::size_type t = prev.find('\n');
    if (t != string::npos) {
        str = prev.substr(0, t + 1);
        prev = prev.substr(t + 1);
        return t + 1;
    }
    int s = 0;
    char buf[1024];
    while (find(buf, buf + s, '\n') == buf + s) {
        int r = read(sock, buf + s, 1023 - s);
        if (r == -1) return -1;
        s += r;
    }
    buf[s] = '\0';
    str = prev + buf;
    t = str.find('\n');
    prev = str.substr(t + 1);
    str = str.substr(0, t + 1);
    return str.size();
}

vector<string> split(string &str)
{
    int s = -1;
    vector<string> ret;
    for (int i = 0; i < (int)str.size(); ++i) {
        if (str[i] == ' ' || str[i] == '\n') {
            if (s != -1) ret.push_back(str.substr(s, i - s));
            s = -1;
        } else if (s == -1) s = i;
    }
    if (s != -1) ret.push_back(str.substr(s));
    return ret;
}

int main(int argc, char *argv[])
{
    string host = "localhost", port = "3000";
    for (int i = 1; i < argc; ++i) {
        string opt = argv[i];
        if (opt == "-H") {
            if (++i >= argc) show_help(argv[0]);
            host = argv[i];
        } else if (opt == "-p") {
            if (++i >= argc) show_help(argv[0]);
            port = argv[i];
        } else if (opt == "-n") {
            if (++i >= argc) show_help(argv[0]);
            name = argv[i];
        } else if (opt == "-c") {
            bgwhite = true;
        } else if (opt == "-x") {
            hint = false;
        } else if (opt == "-h" || opt == "-?") {
            show_help(argv[0]);
        } else {
            cerr << "エラー: 無効なオプション \'" << argv[i] << "\'" << endl;
            show_help(argv[0]);
        }
    }
    
    addrinfo hints, *addr;
    memset(&hints, 0, sizeof(addrinfo));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;
    int sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (sock == -1) { perror("socket"); return 1; }
    if (getaddrinfo(host.c_str(), port.c_str(), &hints, &addr) != 0) {
        cerr << "getaddrinfo failed" << endl; return 1;
    }
    if (connect(sock, addr->ai_addr, addr->ai_addrlen) == -1) {
        perror("connect"); return 1;
    }
    
    send(sock, "OPEN " + name + "\n");
    cout << "待機中..." << endl;
    
    srand(time(NULL));
    string buf;
    while (true) {
        if (turn == mycolor) {
            if (force_pass(turn)) {
                pass();
                print(false);
                send(sock, "MOVE PASS\n");
                continue;
            }
            while (true) {
                cout << "          \r> ";
                pair<uint64_t,uint64_t> ob = board_to_othello_board(mycolor);
                
                buf = pos_to_str(genetic_play(genome, ob.first , ob.second ));
                cout << buf << endl;
                pair<int, int> p = to_pair(buf);
                if (p.first == -1) {
                    cout << "入力が正しくありません。  \r\x1b[A";
                    continue;
                }
                if (!is_valid(p.first, p.second, turn)) {
                    cout << "合法手ではありません。    \r\x1b[A";
                    continue;
                }
                cout << "\x1b[A";
                move(p.first, p.second);
                print(false);
                buf[0] = toupper(buf[0]);
                send(sock, "MOVE " + buf + "\n");
                break;
            }
            continue;
        }
        if (recv(sock, buf) <= 0) break;
        vector<string> v = split(buf);
        if (v[0] == "BYE") {
            cout << "\nサーバーとの接続が終了しました。" << endl;
            for (int i = 0; i < (int)v.size() / 4; ++i)
                cout << v[i * 4 + 1] << ": " << v[i * 4 + 3] << "勝" << v[i * 4 + 4] << "敗" << endl;
            break;
        }
        if (v[0] == "END") {
            if (v[1] == "WIN")  cout << "\nあなたの勝ちです。";
            if (v[1] == "LOSE") cout << "\nあなたの負けです。";
            if (v[1] == "TIE")  cout << "\n引き分けです。";
            if (v[4] != "DOUBLE_PASS") cout << "(" << v[4] << ")";
            cout << "            " << endl;
            mycolor = EMPTY;
            continue;
        }
        if (v[0] == "START") {
            mycolor = v[1] == "BLACK" ? BLACK : WHITE;
            opp_name = v[2];
            rem_time = atoi(v[3].c_str()) / 1000;
            init_board();
            print(true);
        }
        if (v[0] == "MOVE") {
            if (v[1] == "PASS") {
                pass();
            } else {
                pair<int, int> p = to_pair(v[1]);
                move(p.first, p.second);
            }
        }
        if (v[0] == "ACK") {
            rem_time = atoi(v[1].c_str()) / 1000;
        }
        print(false);
    }
    
    close(sock);
}
