#!/bin/bash
curl https://misscolle.com/vote/276/check
curl -F "_method=POST" -e "https://misscolle.com/seisen2016/vote" https://misscolle.com/vote/276/1517
curl https://misscolle.com/vote/276/check
printf "\n"
