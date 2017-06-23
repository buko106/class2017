#!/bin/sh

find ./coreutils-8.9 -name *.c | xargs wc | sort -n | sed -e '$ d' |sed -e 's%[^/]*/%%g' > result.txt
