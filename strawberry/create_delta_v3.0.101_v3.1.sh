#!/bin/bash

# simple diff script by Josua Groeger, 2017
# License: GPLv2

BASE=../../linux-3.0.101
SMDK=../../android_kernel_samsung_smdk4412
STRAW=../../android_kernel_strawberry_i9300

FINI=upgrade3.1-finished.txt
TMPDIFF=delta_strawberry_v3.0.101_v3.1_list.txt
DIFF=delta_strawberry_v3.0.101_v3.1.txt

LINUX31=../../linux-3.1
LINUX32=../../linux-3.2
LINUX33=../../linux-3.3
LINUX34=../../linux-3.4

export LC_ALL=C.UTF-8

function make_diff
{
  FILE="$3"
  # create file list of files (also dirs) that
  # only exist in $1
  # only exist in $2
  # exist in $1 and $2 and are different
  diff -rq "$1" "$2"> "$FILE"

  E1=$(echo "$1"|sed 's/\//\\\//g')
  E2=$(echo "$2"|sed 's/\//\\\//g')

  sed -i "/.gitignore/d" "$FILE"
  sed -i "/.git/d" "$FILE"
  sed -i "s/^Files\ $E1\///g" "$FILE"
  sed -i "s/\ and.*differ//g" "$FILE"
  sed -i "s/^Only\ in\ $E1\///g" "$FILE"
  sed -i "s/^Only\ in\ $E1//g" "$FILE"
  sed -i "s/^Only\ in\ $E2\///g" "$FILE"
  sed -i "s/^Only\ in\ $E2//g" "$FILE"
  sed -i "s/:\ /\//g" "$FILE"
}

function del_finished
{
  FILE="$1"

  for i in $(cat "$FINI");do
    iesc=$(echo "$i"|sed 's/\//\\\//g')
    sed -i "/^$iesc/d" "$FILE"
  done
}

rm "$TMPDIFF"
make_diff "$STRAW" "$BASE" "$TMPDIFF"
del_finished "$TMPDIFF"

function fdiff
{
  if [ -e "$1" ] && [ -e "$2" ];then
    DIFF=$(diff -rq "$1" "$2")
    if [ "$DIFF" == "" ];then
      echo "0"
    else
      echo "!"
    fi
    return
  fi

  if [ ! -e "$1" ] && [ ! -e "$2" ];then
    echo " "
    return
  fi

  if [ -e "$1" ] && [ ! -e "$2" ];then
    echo "<"
  elif [ ! -e "$1" ] && [ -e "$2" ];then
    echo ">"
  fi
}

>"$DIFF"
for j in $(cat "$TMPDIFF");do
  FN=$(fdiff $STRAW/$j $SMDK/$j)
  F0=$(fdiff $STRAW/$j $BASE/$j)
  F1=$(fdiff $STRAW/$j $LINUX31/$j)
  F2=$(fdiff $STRAW/$j $LINUX32/$j)
  F3=$(fdiff $STRAW/$j $LINUX33/$j)
  F4=$(fdiff $STRAW/$j $LINUX34/$j)
  echo "$FN| $F0$F1| $F2$F3$F4: $j">>"$DIFF"
done

