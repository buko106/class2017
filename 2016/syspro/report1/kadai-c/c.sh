#!/bin/sh

COUNT=0


while [ $COUNT -lt 100 ]; do
    printf "http://syspro.is.s.u-tokyo.ac.jp/2015/resume/kadai1/1.pdf.%02d\n" $COUNT | xargs wget -O- >> 1.pdf
    COUNT=$((COUNT + 1 ))
done


