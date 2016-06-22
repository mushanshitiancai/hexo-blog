---
title: 从源码安装git
date: 2016-02-02 14:20:13
tags: linux
---

Centos自带的git版本为1.7.1。算是比较旧了。需要新版本的话就需要自己从源码安装了。

git的参考在`git://git.kernel.org/pub/scm/git/git.git`这个git仓库中。

```
$ sudo yum -y groupinstall "Development Tools"
$ git clone git://git.kernel.org/pub/scm/git/git.git
$ make configure
$ ./configure prefix=<prefix>
$ make && make install
```

make遇到错误：

```
/usr/bin/perl Makefile.PL PREFIX='/home/vagrant/mygit' INSTALL_BASE='' --localedir='/home/vagrant/mygit/share/locale'
Can't locate ExtUtils/MakeMaker.pm in @INC (@INC contains: /usr/local/lib64/perl5 /usr/local/share/perl5 /usr/lib64/perl5/vendor_perl /usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl5 .) at Makefile.PL line 3.
BEGIN failed--compilation aborted at Makefile.PL line 3.
make[1]: *** [perl.mak] 错误 2
make: *** [perl/perl.mak] 错误 2
```

这是因为没有安装perl的相关模块：

    yum install perl-devel

还遇到了错误：

```
Manifying blib/man3/Git.3pm
    SUBDIR templates
    MSGFMT po/build/locale/bg/LC_MESSAGES/git.mo
/bin/sh: msgfmt: command not found
make: *** [po/build/locale/bg/LC_MESSAGES/git.mo] 错误 127
```

这是因为需要安装gettext：

    yum install gettext

## 参考网址
- [“Can’t locate ExtUtils/MakeMaker.pm” while compile git | Mad Coder's Blog](http://madcoda.com/2013/09/cant-locate-extutilsmakemaker-pm-while-compile-git/)
- [Compiler error - msgfmt command not found when compiling git on a shared hosting - Stack Overflow](http://stackoverflow.com/questions/9500898/compiler-error-msgfmt-command-not-found-when-compiling-git-on-a-shared-hosting)
