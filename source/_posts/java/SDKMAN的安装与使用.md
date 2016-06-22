---
title: SDKMAN的安装与使用
date: 2016-03-04 18:36:24
categories: [JAVA]
tags: java
---

从一些文字里看到GVM来管理Groovy。但是Google搜索GVM指向的是[sdkman the Software Development Kit Manager](http://sdkman.io/index.html)。主页上有一句话：

> SDKMAN! is a tool for managing parallel versions of multiple Software Development Kits on most Unix based systems. It provides a convenient Command Line Interface (CLI) and API for installing, switching, removing and listing Candidates. Formerly known as GVM the Groovy enVironment Manager, it was inspired by the very useful RVM and rbenv tools, used at large by the Ruby community.

sdkman的前身是gvm，经过不断发展，现在不单单可以管理groovy了，还可以管理其他的sdk（主要是JVM上的），所以改名叫sdkman了。

sdkman主要是通过控制`PATH`和`*_HOME`这两个环境变量来做到切换各个sdk版本的。

## 安装sdkman

    $ curl -s get.sdkman.io | bash

查看sdkman当前版本：

    $ sdk version
    SDKMAN 3.3.2

默认sdkman会被安装到`~/.sdkman`中，也可以自定义安装目录：

    $ export SDKMAN_DIR="/usr/local/sdkman" && curl -s get.sdkman.io | bash

## 使用sdkman
### 列表可以用sdkman安装的sdk列表

```
$ sdk list
================================================================================
Available Candidates
================================================================================
q-quit                                  /-search down
j-down                                  ?-search up
k-up                                    h-help
--------------------------------------------------------------------------------
Groovy (2.4.5)                                       http://www.groovy-lang.org/

Groovy is a powerful, optionally typed and dynamic language, with static-typing
and static compilation capabilities, for the Java platform aimed at multiplying
developers’ productivity thanks to a concise, familiar and easy to learn syntax.
It integrates smoothly with any Java program, and immediately delivers to your
application powerful features, including scripting capabilities, Domain-Specific
Language authoring, runtime and compile-time meta-programming and functional
programming.

                                                            $ sdk install groovy
--------------------------------------------------------------------------------
Scala (2.11.7)                                        http://www.scala-lang.org/
...
```


目前可以使用sdkman管理的sdk有：

```
Ant
AsciidoctorJ
Ceylon
CRaSH
Gaiden
Glide
Gradle
Grails
Griffon
Groovy
GroovyServ
JBake
JBoss Forge
Kotlin
Lazybones
Maven
sbt
Scala
Spring Boot
Vert.x
```

### 安装一个sdk

    $ sdk install groovy
    
    或者指定具体版本：
    
    $ sdk install groovy 2.4.6
    
    或者安装本地的文件：
    
    $ sdk install grails 3.1.0-SNAPSHOT /path/to/grails-3.1.0-SNAPSHOT


### 列出一个sdk的所有可用版本

```
$ sdk list groovy 
===============================================================================
Available Groovy Versions
===============================================================================
 > * 2.4.4                2.3.1                2.0.8                1.8.3
     2.4.3                2.3.0                2.0.7                1.8.2
     2.4.2                2.2.2                2.0.6                1.8.1
     2.4.1                2.2.1                2.0.5                1.8.0
     2.4.0                2.2.0                2.0.4                1.7.9
     2.3.9                2.1.9                2.0.3                1.7.8
     2.3.8                2.1.8                2.0.2                1.7.7
     2.3.7                2.1.7                2.0.1                1.7.6
     2.3.6                2.1.6                2.0.0                1.7.5
     2.3.5                2.1.5                1.8.9                1.7.4
     2.3.4                2.1.4                1.8.8                1.7.3
     2.3.3                2.1.3                1.8.7                1.7.2
     2.3.2                2.1.2                1.8.6                1.7.11
     2.3.11               2.1.1                1.8.5                1.7.10
     2.3.10               2.1.0                1.8.4                1.7.1

===============================================================================
+ - local version
* - installed
> - currently in use
===============================================================================
```

### 使用sdk的具体某个版本

    $ sdk use groovy 2.4.4

`use`命令只会在本shell中使用这个sdk的这个版本。如果你想要每个shell中默认使用这个版本，可以使用`default`命令。

### 指定sdk的默认版本

    $ sdk default scala 2.11.6

这会让所有新shell使用这个版本的sdk。

### 查看sdk的当前版本

```
查看否个sdk的当前版本：
$ sdk current grails
  Using grails version 2.4.3

查看全部sdk的当前版本：
$ sdk current
  Using:
  groovy: 2.1.0
  scala: 2.11.7
```

### 查看过期的版本

```
查看某个sdk的过期版本：
$ sdk outdated springboot
  Outdated:
  springboot (1.2.4.RELEASE, 1.2.3.RELEASE < 1.2.5.RELEASE)

查看全部的sdk的过期版本：
$ sdk outdated
  Outdated:
  gradle (2.3, 1.11, 2.4, 2.5 < 2.6)
  grails (2.5.1 < 3.0.4)
  springboot (1.2.4.RELEASE, 1.2.3.RELEASE < 1.2.5.RELEASE)
```

### 使用离线模式
离线模式可以在没有网络的情况下使用sdkman

```
$ sdk offline enable
  Forced offline mode enabled.

$ sdk offline disable
  Online mode re-enabled!
```

### 更新sdkman本身

```
$ sdk selfupdate

强制重复安装：
$ sdk selfupdate force
```

## 参考地址
- [sdkman the Software Development Kit Manager](http://sdkman.io/index.html)