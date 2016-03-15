#!/bin/bash

cd "$(dirname "$0")"

function git_change(){
  expr $(git status --porcelain 2>/dev/null | wc -l)
}

if [ "$1" = "d" ];then
    if [ ! git_change = "0" ];then
      echo "not modified."
      exit
    fi
    hexo g && hexo d
    git add .
    git commit -m "Site updated: `date +%Y-%m-%d\ %H:%M:%S`"
    git push origin master
    echo -e "deploy `date +%Y-%m-%d\ %H:%M:%S`\n" >> ~/blog_log
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
