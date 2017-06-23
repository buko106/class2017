#!/bin/bash


##################################################設定項目
# event=
# date=
# hour=
# min=
# mode=
# # 0 Deadline with time    $eventの締切は$i日後の$date$youbi $hour:$minです
# # 1 Deadline without time $eventの締切は$i日後の$date$youbiです
# # 2 No lecture            $date$youbiの$eventです。（$i日後）
# # 3 Schedule              $date$youbiは$eventです。（$i日後）
# remind=() #remind n days before event
##################################################ここまで
##################################################Fixed Parameter
apikey=eb11547c397b57b8876adae74ef9ece5602b6111
name=is16er
adr=http://twitdelay.appspot.com/api/post
##################################################

echo "INPUT MODE"
echo "0 for Deadline with time"
echo "1 for Deadline without time"
echo "2 for No lecture"
echo "3 for Schedule"
echo "4 for Exam"
echo -n ">"
read -n 1 mode

echo ""
case $mode in
    0 )echo 【Deadline】EVENTの締切はN日後のYYYY/MM/DD HOUR:MINです。;;
    1 )echo 【Deadline】EVENTの締切はN日後のYYYY/MM/DDです。;;
    2 )echo 【No lecture】YYYY/MM/DDのEVENTです。（N日後）;;
    3 )echo 【Schedule】YYYY/MM/DDはEVENTです。（N日後）;;
    4 )echo 【Exam】YYYY/MM/DDはEVENTです。（N日後）;;
esac
echo "INPUT EVENT"
echo -n ">"
read event
echo "INPUT DAY(YYYY/MM/DD)"
echo -n "YYYY>"
read -n 4 YYYY
echo ""
echo -n "MM>"
read -n 2 MM
echo ""
echo -n "DD>"
read -n 2 DD
echo ""
echo "INPUT TIME"
echo -n "HH>"
read -n 2 hour
echo ""
echo -n "MM>"
read -n 2 min
echo ""
echo "REMIND N DAYS BEFORE"
echo -n ">"
read -a remind

date=$(printf "%s/%s/%s" $YYYY $MM $DD)
youbi=（$(date -d $date | sed -e 's/.*\(.\)曜.*/\1/')）

case $mode in
    0 )echo 【Deadline】$eventの締切は${remind[0]}日後の$date$youbi $hour:$minです。;;
    1 )echo 【Deadline】$eventの締切は${remind[0]}日後の$date$youbiです。;;
    2 )echo 【No lecture】$date$youbiの$eventです。（${remind[0]}日後）;;
    3 )echo 【Schedule】$date$youbiは$eventです。（${remind[0]}日後）;;
    4 )echo 【Exam】$date$youbiは$eventです。（${remind[0]}日後）
esac

echo "OK?"
echo -n "y/n>"
read -n 1 ans
if [ $ans = "y" ]; then
    echo ""
else
    echo ""
    exit 0
fi

for i in ${remind[@]}
do

at=$(date -R -d "$date $hour:$min $i day ago"| tr -d '\n' | tr ' ' + )

case $mode in
    0 )status="$(echo 【Deadline】$eventの締切は$i日後の$date$youbi $hour:$minです。 | nkf -WwMQ | sed 's/=$//g' | tr -d '\n' | tr = %)";;
    1 )status="$(echo 【Deadline】$eventの締切は$i日後の$date$youbiです。 | nkf -WwMQ | sed 's/=$//g' | tr -d '\n' | tr = %)";;
    2 )status="$(echo 【No lecture】$date$youbiの$eventです。（$i日後） | nkf -WwMQ | sed 's/=$//g' | tr -d '\n' | tr = %)";;
    3 )status="$(echo 【Schedule】$date$youbiは$eventです。（$i日後） | nkf -WwMQ | sed 's/=$//g' | tr -d '\n' | tr = %)";;
    4 )status="$(echo 【Exam】$date$youbiは$eventです。（$i日後） | nkf -WwMQ | sed 's/=$//g' | tr -d '\n' | tr = %)";;
esac

dataoption=--post-data="'user_id=$name&screen_name=$name&api_key=$apikey&status=$status&at=$at"

wget  $dataoption http://twitdelay.appspot.com/api/post

done

cat post*

rm post*

echo ""
