---
title: gun global使用笔记
tags: emacs
date: 2016-02-03 16:10:52
---


global是一个由一家日本公司开发的源代码tag系统。和ctags是一类的工具。不过比ctags要强大很多，具体的对比可以参考这个表格：([表格地址][global_compare])。

## 安装
mac：

    brew install global

centos源码安装：

```
$ sudo yum -y groupinstall "Development Tools"
$ sudo yum -y install gperf
$ sudo yum -y install libtool-ltdl-devel

$ wget http://tamacom.com/global/global-6.5.2.tar.gz
$ tar zxvf global-6.5.2.tar.gz
$ cd global-6.5.2
$ sh reconf.sh 
$ ./configure --prefix=<PREFIX> --with-exuberant-ctags=/usr/bin/ctags
$ make
$ sudo make install
```

一开始我在运行`sh reconf.sh`期间我遇到了错误：

    `COPYING.LIB' not found in `/usr/share/libtool/libltdl'

这是因为没有安装`libtool-ltdl-devel`。参考[帖子][libltdl_problem]。

## 生成tag文件

    $ cd source_code_dir
    $ gtags

global会遍历改目录下的所有子目录，处理所有代码文件，然后在当前目录下生成三个文件：

    $ ls G*
    GPATH   GRTAGS  GTAGS

这三个文件：
- `GTAGS`   定义数据库
- `GRTAGS`  引用数据库
- `GPATH`   路径名数据库

## 基本使用
以下的例子翻译自global的官方文档。假设目前有这样一个项目：

```
/home/user/
 |
 |-ROOT/      <- the root of source tree (GTAGS,GRTAGS,...)
    |
    |- README       .....   +---------------+
    |                       |The function of|
    |                       +---------------+
    |- DIR1/
    |  |
    |  |- fileA.c   .....   +---------------+
    |  |                    |main(){        |
    |  |                    |       func1();|
    |  |                    |       func2();|
    |  |                    |}              |
    |  |                    +---------------+
    |  |
    |  |- fileB.c   .....   +---------------+
    |                       |func1(){ ... } |
    |                       +---------------+
    |- DIR2/
       |
       |- fileC.c   .....   +---------------+
                            |#ifdef X       |
                            |func2(){ i++; }|
                            |#else          |
                            |func2(){ i--; }|
                            |#endif         |
                            |func3(){       |
                            |       func1();|
                            |}              |
                            +---------------+
```

一旦你在项目跟目录下生产了tags文件。你可以在项目中的任何位置使用`global`命令。但是显示的结果是受当前目录影响的相对路径：

```
$ cd /home/user/ROOT
$ global func1
DIR1/fileB.c            # func1() 定义在 fileB.c 中
$ cd DIR1
$ global func1
fileB.c                 # 相对于 DIR1 的路径
$ cd ../DIR2
$ global func1
../DIR1/fileB.c         # 相对于 DIR2 的路径
```

`-r`参数获取的是对tag的引用：

```
$ global -r func2
../DIR1/fileA.c         # func2() 被文件 fileA.c 所引用
```

`-x`参数会显示更多的细节，和ctags的`-x`是类似的

```
$ global func2
DIR2/fileC.c
$ global -x func2
func2              2 DIR2/fileC.c       func2(){ i++; }
func2              4 DIR2/fileC.c       func2(){ i--; }
```

`-a`参数会显示绝对路径

```
$ global -a func1
/home/user/ROOT/DIR1/fileB.c
```

`-s`命令定位没有定义在`GTAGS`中的标示符（疑问：没定义在GTAGS中，他又是如何找到这个tag的？如果能找到这个tag，为何又不定义在GTAGS中？）

```
$ global -xs X
X                  1 DIR2/fileC.c #ifdef X
```

`-g`命令类似`egrep`，可以搜索符合特定正则表达式的行。但是他比egrep，因为他搜索的是项目工程，而不需要指定特定文件。

```
$ global -xg '#ifdef'
#ifdef             1 DIR2/fileC.c #ifdef X
```

还可以搭配额外参数使用：
`-O` 只搜索文本文件
`-o` 搜索文本文件和代码文件
`-l` 只在当前目录下搜索

`-e`，`-G`，`-i`这些egrep的参数也可以使用。还可以使用`--result=grep`参数。

`-P`命令定位包含特定格式的路径：

```
$ global -P fileB
DIR1/fileB.c
$ global -P '1/'
DIR1/fileA.c
DIR1/fileB.c
$ global -P '\.c$'
DIR1/fileA.c
DIR1/fileB.c
DIR2/fileC.c
```

`-f`命令显示特定文件中的所有tag：

```
$ global -f DIR2/fileC.c
func2              2 DIR2/fileC.c   func2(){ i++; }
func2              4 DIR2/fileC.c   func2(){ i--; }
func3              6 DIR2/fileC.c   func3(){
```

`-l`参数只会在当前目录下搜索：

```
$ cd DIR1
$ global -xl func[1-3]
func1        1 fileB.c      func1(){...}
```

## 高级使用
### 针对指定的文件生成tag
你可以指定特定的需要生产tag的文件：

```
$ find . -type f -print >/tmp/list     # make a file set
$ vi /tmp/list                         # customize the file set
$ gtags -f /tmp/list
```

### 把tag文件生成在外部目录中
如果你的代码在不可写介质上（比如光盘），你可以在外部目录建立TAGS文件。

```
$ mkdir /var/dbpath
$ cd /cdrom/src                 # the root of source tree
$ gtags /var/dbpath             # make tag files in /var/dbpath
$ export GTAGSROOT=`pwd`
$ export GTAGSDBPATH=/var/dbpath
$ global func
```

还有一个方法：global还会在`/usr/obj + <current directory>`目录中寻找tag文件，所以你可以这么做：

```
$ cd /cdrom/src                 # the root of source tree
$ mkdir -p /usr/obj/cdrom/src
$ gtags /usr/obj/cdrom/src      # make tag files in /usr/obj/cdrom/src
$ global func
```

你可以使用`-O, --objdir`参数来修改obj目录。

### 同时搜索多个代码仓库中标示符
如果你搜索的标示符不在当前的代码仓库中，比如是工具库中的标示符，你可以通过设置`GTAGSLIBPATH`来指定额外的代码仓库，前提是这些仓库都需要用gtags生成一下。

```
$ pwd
/develop/src/mh                 # this is a source project
$ gtags
$ ls G*TAGS
GRTAGS  GTAGS
$ global mhl
uip/mhlsbr.c                    # mhl() is found
$ global strlen                 # strlen() is not found
$ (cd /usr/src/lib; gtags)      # library source
$ (cd /usr/src/sys; gtags)      # kernel source
$ export GTAGSLIBPATH=/usr/src/lib:/usr/src/sys
$ global strlen
../../../usr/src/lib/libc/string/strlen.c  # found in library
$ global access
../../../usr/src/sys/kern/vfs_syscalls.c   # found in kernel
```

还有一种更直接的方法，直接把相关的代码软链接过来，global会把他们认为是当前工程的：

```
$ ln -s /usr/src/lib .
$ ln -s /usr/src/sys .
$ gtags
$ global strlen
lib/libc/string/strlen.c
$ global access
sys/kern/vfs_syscalls.c
```

### 标示符补全
如果你忘记了标示符的全名，可以使用`-c`来补全标示符的名字

```
$ global -c kmem                # maybe k..k.. kmem..
kmem_alloc
kmem_alloc_pageable
kmem_alloc_wait
kmem_free
kmem_free_wakeup
kmem_init
kmem_malloc
kmem_suballoc                   # This is what I need!
$ global kmem_suballoc
../vm/vm_kern.c
```

其他的一些高级技巧，比如bash中自动补全，可以参考global官方文档。

## 高级话题
### 配置global

```
# cp gtags.conf /etc/gtags.conf         # system wide config file.
# vi /etc/gtags.conf

$ cp gtags.conf $HOME/.globalrc         # personal config file.
$ vi $HOME/.globalrc
```

### 如何使用ctags作为global的后备

```
# Installation of GLOBAL
# It assumed that ctags command is installed in '/usr/local/bin'.

$ ./configure --with-exuberant-ctags=/usr/local/bin/ctags
$ make
$ sudo make install

# Executing of gtags
# It assumed that GLOBAL is installed in '/usr/local'.

$ export GTAGSCONF=/usr/local/share/gtags/gtags.conf
$ export GTAGSLABEL=ctags
$ gtags                         # gtags invokes Exuberant Ctags internally

or

$ gtags --gtagslabel=ctags
```

## 和其他工具结合使用
global可以和许多工具结合使用。

- bash
- less
- vim
- emacs
- cscope
- Doxygen

具体的可以参考[官方文档][global_tools]。

global官方提供了emacs的插件。不过应该会比较原始。网上目前有两个类似插件[ggtags][ggtags]，[helm-gtags][helm-gtags]，可以找个时间试用一下。

## FAQ
关于global的场景问题，可以这么看：

    more /usr/local/share/gtags/FAQ

## 参考网址
- [GNU GLOBAL source code tagging system](http://www.gnu.org/software/global/global.html)
- [Tutorial](https://www.gnu.org/software/global/globaldoc_toc.html)

[global_compare]: https://github.com/OpenGrok/OpenGrok/wiki/Comparison-with-Similar-Tools "Comparison with Similar Tools · OpenGrok/OpenGrok Wiki"
[libltdl_problem]: http://forums.fedoraforum.org/showthread.php?t=188338 "Problem installing gift with ltdl library - FedoraForum.org"
[global_tools]: https://www.gnu.org/software/global/globaldoc_toc.html#Applications "Various applications"
[helm-gtags]: https://github.com/syohex/emacs-helm-gtags "syohex/emacs-helm-gtags: GNU GLOBAL helm interface"
[ggtags]: https://github.com/leoliu/ggtags "leoliu/ggtags - Emacs Lisp"