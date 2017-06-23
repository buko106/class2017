#include <stdio.h>
#include <stdint.h>

/*
 *  fadd.c に fadd 関数のみを定義し (main 関数は含めない) 、
 *  gcc fadd.c Verify.c などとしてコンパイルしてください
 */

/*  [計算結果が NaN になる場合の期待される出力]
 *  SYSTEM_DEFAULT:     実際の浮動小数点数の演算結果と比較する
 *  NaN_ANY:            NaN ならばどれでも良いものとする
 *  固定された値を指定する場合は 0x7fc00000 などとする */
#define NaN         NaN_ANY

/*  [非正規化数の扱い]
 *  SYSTEM_DEFAULT:     非正規化数に対応する
 *  SIGN_CHECK:         入力の非正規化数は概ね ±0 として扱う
 *                      非正規化数どうしの計算結果は 0 とするが、
 *                      符号は実際の演算結果に合わせる
 *  REGARD_ZERO:        入力の非正規化数を完全に ±0 として見なす
 *  SUBNORMAL_ANY:      演算の入出力に非正規化数が絡む場合はチェックを緩める
 *  OUT_SIGNED_ZERO:    正規化数どうしの演算結果が非正規化数になる場合は
 *                      符号付き 0 に潰す (ビットフラグで指定)
 *  OUT_PLUS_ZERO:      正規化数どうしの演算結果が非正規化数になる場合は
 *                      +0 に潰す (ビットフラグで指定) */
#define SUBNORMAL   (SUBNORMAL_ANY | OUT_SIGNED_ZERO)

/*  [丸め]
 *  ROUND_EVEN:     偶数丸め
 *  TRUNCATE:       0方向への丸め (チェックが雑になります) */
#define ROUNDING    ROUND_EVEN


#define SYSTEM_DEFAULT  0
#define NaN_ANY         1
#define SIGN_CHECK      1
#define REGARD_ZERO     2
#define SUBNORMAL_ANY   3
#define SMASK           3
#define OUT_SIGNED_ZERO 4
#define OUT_PLUS_ZERO   8
#define ROUND_EVEN      0
#define TRUNCATE        1

#define EXP(x)          (((x) >> 23) & 0xff)
#define MAN(x)          ((x) & 0x7fffff)
#define ISNaN(x)        (EXP(x) == 0xff && MAN(x) != 0)
#define ISINF(x)        (EXP(x) == 0xff && MAN(x) == 0)
#define ISSUB(x)        (EXP(x) == 0)
#define mask(x, y)      (((1u << ((y) - (x))) - 1u) << (x))

uint32_t fadd(uint32_t, uint32_t);

const char *test[] = {
    "0 + 0",
    "x + 0",
    "x + (-x)",
    "inf + inf",
    "x + inf",
    "NaN + NaN",
    "x + NaN",
    "Sub + Sub",
    "Norm + Sub",
    "Norm + Norm",
    "x + y = inf",
    "roundings"
};

void print_bin(uint32_t x) {
    int i;
    for (i = 31; i >= 0; --i) {
        printf("%d", (x >> i) & 1);
        if (i == 31 || i == 23) printf(" ");
    }
    printf("\n");
}

int main()
{
    int i, all, err;
    union F { uint32_t u; float f; } f[2], out, ans;
    
    FILE *fp;
    fp = fopen("Verify.bin", "rb");
    if (fp == NULL) { perror("Verify.bin"); return 1; }
    
    f[0].u = f[1].u = 0;
    
    for (i = 0; i < 12; ++i) {
        all = err = 0;
        while (1) {
            out.u = fadd(f[0].u, f[1].u);
            ans.f = f[0].f + f[1].f;
            if (ISNaN(ans.u)) {
                if (NaN == NaN_ANY)
                    ans.u = ISNaN(out.u) ? out.u : ans.u;
                else if (NaN != SYSTEM_DEFAULT)
                    ans.u = NaN;
            } else if (ISSUB(f[0].u) && ISSUB(f[1].u)) {
                if ((SUBNORMAL & SMASK) == SIGN_CHECK)
                    ans.u &= ~mask(0, 31);
                else if ((SUBNORMAL & SMASK) == REGARD_ZERO)
                    ans.u = f[0].u & f[1].u & ~mask(0, 23);
                else if ((SUBNORMAL & SMASK) == SUBNORMAL_ANY)
                    if (out.u != ans.u && ISSUB(out.u))
                        ans.u = out.u;
            } else if (ISSUB(f[0].u) || ISSUB(f[1].u)) {
                if ((SUBNORMAL & SMASK) == SIGN_CHECK || 
                    (SUBNORMAL & SMASK) == REGARD_ZERO)
                    ans.u = ISSUB(f[0].u) ? f[1].u : f[0].u;
                else if ((SUBNORMAL & SMASK) == SUBNORMAL_ANY)
                    if (out.u == ISSUB(f[0].u) ? f[1].u : f[0].u)
                        ans.u = ISSUB(f[0].u) ? f[1].u : f[0].u;
            } else if (ISSUB(ans.u)) {
                if (SUBNORMAL & OUT_SIGNED_ZERO)
                    ans.u &= ~mask(0, 23);
                else if (SUBNORMAL & OUT_PLUS_ZERO)
                    ans.u = 0;
                else if ((SUBNORMAL & SMASK) == SUBNORMAL_ANY)
                    if (ISSUB(out.u)) ans.u = out.u;
            }
            if (out.u != ans.u && (ROUNDING == ROUND_EVEN || out.u + 1 != ans.u)) {
                if (err == 0) printf("%2d.  %-16sFailed\n", i + 1, test[i]);
                if (err < 5) {
                    printf("  case #%d: ", err + 1);
                    printf(           "input1: "); print_bin(f[0].u);
                    printf("           input2: "); print_bin(f[1].u);
                    printf("           output: "); print_bin(out.u);
                    printf("           answer: "); print_bin(ans.u);
                }
                ++err;
            }
            ++all;
            if (fread(f, sizeof(union F), 2, fp) == 0) break;
            if (f[0].u == 0 && f[1].u == 0) break;
        }
        if (err == 0) {
            printf("%2d.  %-16sSuccess\n", i + 1, test[i]);
        } else if (err > 0) {
            printf("  total error: %d/%d\n", err, all);
        }
        if (fread(f, sizeof(union F), 2, fp) == 0) break;
    }
    
    fclose(fp);
    
    return 0;
}

