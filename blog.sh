#!/bin/bash
# author: mazhibin
# log   : 2016-02-25 新建
#       : 2016-03-15 获取git仓库状态，只在有修改的情况下，才会执行发布操作
#       : 2016-03-18 修复判断git仓库状态的bug（没有搞懂shell的if语句导致的）


if [ "$#" = 0 -o "$1" = "-h" ];then
  echo "Usage: sh blog.sh [dnp]"
  echo "       d  deployment hexo to github"
  echo "       n  create a new blog"
  echo "       p  publish draft to post"
fi

cd "$(dirname "$0")"

# 判断git仓库是否有未提交的修改
function git_change(){
  [ $(git status --porcelain 2>/dev/null | wc -l) != "0" ]
}

# 发布最新博客到github，同时也把hexo参考提交到github
# 如果没有修改则不会进行提交
if [ "$1" = "d" ];then
    if ! git_change;then
      echo "not modified."
      exit
    fi
    hexo g && hexo d
    git add .
    git commit -m "Site updated: `date +%Y-%m-%d\ %H:%M:%S`"
    git push origin master
    echo -e "deploy `date +%Y-%m-%d\ %H:%M:%S`\n" >> ~/blog_log
fi

# 新建博客，也可以新建草稿(可以指定子目录)
if [ "$1" = "n" ];then
  blog_dir="other"     # 不指定博客子目录，都移动到other下
  blog_name="$2"
  if [[ "$2" =~ "/" ]];then
    # 指定博客在子目录中
    blog_dir=$(echo "$2" | sed 's/\/.*//')
    blog_name=$(echo "$2" | sed 's/.*\///')
  fi

  # 新建
  if [ "$#" = "3" ];then
      hexo n "$blog_name" "$3"
  else
      hexo n "$blog_name"
  fi

  # 移动
  
fi

# 发布草稿到正式博客
if [ "$1" = "p" ];then
    hexo p "$2"
fi
