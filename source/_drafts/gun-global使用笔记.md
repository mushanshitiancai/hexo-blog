---
title: gun global使用笔记
tags: [tools]
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
$ ./configure
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



## FAQ
关于global的场景问题，可以这么看：

    more /usr/local/share/gtags/FAQ

## 参考网址
- [GNU GLOBAL source code tagging system](http://www.gnu.org/software/global/global.html)
- [Tutorial](https://www.gnu.org/software/global/globaldoc_toc.html)

[global_compare]: https://github.com/OpenGrok/OpenGrok/wiki/Comparison-with-Similar-Tools "Comparison with Similar Tools · OpenGrok/OpenGrok Wiki"
[libltdl_problem]: http://forums.fedoraforum.org/showthread.php?t=188338 "Problem installing gift with ltdl library - FedoraForum.org"