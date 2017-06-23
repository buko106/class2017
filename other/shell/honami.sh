#!/bin/bash
curl https://misscolle.com/vote/278/check
curl -F "_method=POST" -e "https://misscolle.com/todai2016/vote" https://misscolle.com/vote/278/1528
curl https://misscolle.com/vote/278/check
printf "\n"
