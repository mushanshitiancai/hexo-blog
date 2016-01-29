#!/bin/bash

cd "$(dirname "$0")"

if [ "$1" = "d" ];then
    hexo g && hexo d
    git add .
    git commit -m "Site updated: `date +%Y-%m-%d\ %H:%M:%S`"
    git push origin master
fi

if [ "$1" = "n" ];then
    if [ "$#" = "3" ];then
        hexo n "$2" "$3"
    else
        hexo n "$2"
    fi
fi


if [ "$1" = "p" ];then
    hexo p "$2"
fi
