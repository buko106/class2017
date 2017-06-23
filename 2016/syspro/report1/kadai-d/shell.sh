#!/bin/sh

for fname in *.cpp; do
    sed $fname -e "s/NEET the 3rd/IchiroHiraide/g" | sed -e "s/neet3@example.com/buko1062000@yahoo.co.jp/g" | sed -e "s/[ ]*$"//g > ${fname%.cpp}.cc
    rm ${fname%.cpp}.cpp
done
