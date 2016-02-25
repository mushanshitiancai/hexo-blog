---
title: 【TODO】hexo辅助脚本
date: 2016-02-25 10:46:13
tags: blog
---

hexo的命令比较简单，为了自动化，我写了一个脚本。

TODO：
- [ ] 获取git仓库状态，只在有修改的情况下，才会执行发布操作

```
#!/bin/bash

cd "$(dirname "$0")"

if [ "$1" = "d" ];then
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
```


    0 */12 * * * /Users/mazhibin/project/blog/blog/blog.sh d >/dev/null 2>&1

## 参考文章
