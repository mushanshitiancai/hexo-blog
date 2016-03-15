#!/bin/bash
# author: mazhibin
# log   : 2016-02-25 新建
#       : 2016-03-15 获取git仓库状态，只在有修改的情况下，才会执行发布操作


if [ "$#" = 0 -o "$1" = "-h" ];then
  echo "Usage: sh blog.sh [dnp]"
  echo "       d  deployment hexo to github"
  echo "       n  create a new blog"
  echo "       p  publish draft to post"
fi

cd "$(dirname "$0")"

# 判断git仓库是否有未提交的修改
function git_change(){
  expr $(git status --porcelain 2>/dev/null | wc -l)
}

# 发布最新博客到github，同时也把hexo参考提交到github
# 如果没有修改则不会进行提交
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

# 新建博客，也可以新建草稿
if [ "$1" = "n" ];then
    if [ "$#" = "3" ];then
        hexo n "$2" "$3"
    else
        hexo n "$2"
    fi
fi

# 发布草稿到正式博客
if [ "$1" = "p" ];then
    hexo p "$2"
fi
