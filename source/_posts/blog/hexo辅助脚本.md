---
title: 【TODO】hexo辅助脚本
date: 2016-02-25 10:46:13
tags: blog
---

hexo的命令比较简单，为了自动化，我写了一个脚本。

TODO：
- [x] 获取git仓库状态，只在有修改的情况下，才会执行发布操作 -- 2016年03月15日
- [ ] 脚本bug，无论如何都显示not modified
- [ ] 提交信息显示更详细的信息（xx博客修改/增加），而不是乏味的site update。

## 判断git参数是否干净

--porcelain
Give the output in an easy-to-parse format for scripts. This is similar to the short output, but will remain stable across Git versions and regardless of user configuration. See below for details.

- [shell - Checking for a dirty index or untracked files with Git - Stack Overflow](http://stackoverflow.com/questions/2657935/checking-for-a-dirty-index-or-untracked-files-with-git)
- [Git - git-status Documentation](https://git-scm.com/docs/git-status)

## 脚本

```
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
```


    0 */12 * * * /Users/mazhibin/project/blog/blog/blog.sh d >/dev/null 2>&1

## 参考文章

