---
title: shell script学习笔记
date: 2016-02-22 16:13:23
tags: linux
---

![](/img/shell/第11章认识与学习shell.png)

![](/img/shell/shell_script.png)

## 问题
### `$@`和`$*`的区别？
`$@`代表`"$1"`，`"$2"`，`"$n"`的意思，每个变量是独立的，用双引号括起来。
`$*`代表`"$1c$2c$3"`，其中`c`是分隔符，默认为空格键。

因为`$@`把每个变量用双引号括起来了，保证了每个变量之间不会混淆，所以一般情况下只要使用`$@`就行了。

**注意：**使用`$@`时，一定要用双引号括起来！(总之shell编程中引号是多多益善啊)

请看例子，调用为：`sh text.sh "1 2" 3`

```
#!/bin/bash

echo $1    # 1 2
echo $2    # 3
echo $*    # 1 2 3
echo $@    # 1 2 3
echo "$*"  # 1 2 3
echo "$@"  # 1 2 3

# 执行时，带入参数"1 2" "3"，就会很清晰了.
# 执行时，最外层的双引号会被拿掉

# 没加引号的时候，参数本身的引号就被拿掉了
# for var in 1 2 3
for var in $*
do
    echo $var
done
# 1
# 2
# 3

# for var in 1 2 3
for var in $@
do
    echo $var
done
# 1
# 2
# 3

# for var in "1 2 3"
for var in "$*"
do
    echo $var
done
# 1 2 3

# 加了双引号后$@才表现正常
# for var in "1 2" "3"
for var in "$@"
do
    echo $var
done
# 1 2
# 3
```





## 参考文章
- 《鸟哥的Linux私房菜 基础学习篇》
- 

