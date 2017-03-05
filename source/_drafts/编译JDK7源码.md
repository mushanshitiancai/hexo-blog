---
title: 编译JDK7源码
date: 2016-12-26 08:36:09
categories: [Java,JDK]
tags: java
---

打算试试编译JDK，深入学习一下。

<!-- more -->

## 准备

我使用的机器是MacBook，系统是OS X 10.11.6。

OpenJDK官网：[OpenJDK](http://openjdk.java.net/)

下载OpenJDK源码：[OpenJDK 7 Updates Project Source Releases][OpenJDK 7 Updates Project Source Releases]，这里我下载到的是2013年九月出的7u40，应该是JDK7最后一个版本了。

下载NetBeans:[NetBeans IDE 下载][NetBeans IDE 下载]，选择支持C/C++的版本。

解压JDK后，目录下有一个README和README-builds.html，分别是简单版和详细版编译帮助。其中简单版的如下：

```
Simple Build Instructions:

  0. Get the necessary system software/packages installed on your system, see
     http://hg.openjdk.java.net/jdk7/build/raw-file/tip/README-builds.html

  1. If you don't have a jdk6 installed, download and install a JDK 6 from
     http://java.sun.com/javase/downloads/index.jsp
     Set the environment variable ALT_BOOTDIR to the location of JDK 6.

  2. Check the sanity of doing a build with your current system:
       make sanity
     See README-builds.html if you run into problems.

  3. Do a complete build of the OpenJDK:
       make all
     The resulting JDK image should be found in build/*/j2sdk-image
```

我编写了一个脚本（参考《深入理解Java虚拟机》）来处理需要准备的环境变量等：

```
// my-build.sh
export ALT_BOOTDIR="/Library/Java/JavaVirtualMachines/jdk1.8.0_60.jdk/Contents/Home"
```

然后执行

```
source my-build.sh && make sanity
```

报错如下：

```
WARNING: LANG has been set to zh_CN.UTF-8, this can cause build failures.
         Try setting LANG to 'C'.

ERROR: The Compiler version is undefined.

ERROR: Your CLASSPATH environment variable is set.  This will
       most likely cause the build to fail.  Please unset it
       and start your build again.

ERROR: FreeType version  2.3.0  or higher is required.
 /bin/mkdir -p /Users/mazhibin/project/jdk/openjdk/build/macosx-x86_64/btbins
rm -f /Users/mazhibin/project/jdk/openjdk/build/macosx-x86_64/btbins/freetype_versioncheck
Failed to build freetypecheck.
```

其中第一个ERROR，参考文章[Mac OS下编译openJDK碰到的问题][Mac OS下编译openJDK碰到的问题]，是因为Xcode5.0之后不再提供llvm-gcc与llvm-g++这两样东西，编译jdk是需要这两个。解决方法是在你的Xcode的/usr/bin(/Applications/Xcode.app/Contents/Developer/usr/bin 这是我的目录仅供参考)下做一个ln -s的链接连到/usr/bin（这个/usr/bin与前面的不同）的 llvm-g++ llvm-gcc中

```
sudo ln -s /usr/bin/llvm-g++ /Applications/Xcode.app/Contents/Developer/usr/bin/llvm-g++
sudo ln -s /usr/bin/llvm-gcc /Applications/Xcode.app/Contents/Developer/usr/bin/llvm-gcc
```

修改my-build.sh：

```
// my-build.sh
export ALT_BOOTDIR="/Library/Java/JavaVirtualMachines/jdk1.8.0_60.jdk/Contents/Home"

export LANG=C

unset CLASSPATH
```

再次运行`source my-build.sh && make sanity`，显示Sanity check passed。

然后执行`make`进行编译。

错误：

```
[javac] /Users/mazhibin/project/jdk/openjdk/langtools/src/share/classes/com/sun/tools/javac/comp/Resolve.java:2182: 警告: [overrides] 类Resolve.InapplicableSymbolsError.Candidate覆盖了 equals, 但该类或任何超类都未覆盖 hashCode 方法
[javac]         private class Candidate {
[javac]                 ^
[javac] 错误: 发现警告, 但指定了 -Werror
```

参考[编译OpenJDK出现问题][编译OpenJDK出现问题]，可能是因为我的Bootstrap JDK设置的是JDK8的问题。所以打算改为编译JDK8来试试看：

下载JDK8源码：[OpenJDK™ Source Releases](http://download.java.net/openjdk/jdk8/)

简单构建说明发生了一点变化：

```
Simple Build Instructions:

  0. Get the necessary system software/packages installed on your system, see
     http://hg.openjdk.java.net/jdk8/jdk8/raw-file/tip/README-builds.html

  1. If you don't have a jdk7u7 or newer jdk, download and install it from
     http://java.sun.com/javase/downloads/index.jsp
     Add the /bin directory of this installation to your PATH environment
     variable.

  2. Configure the build:
       bash ./configure

  3. Build the OpenJDK:
       make all
     The resulting JDK image should be found in build/*/images/j2sdk-image
```

已经不再需要`ALT_BOOTDIR`这个环境变量了。只要在PATH中有JDK的/bin目录即可。

执行`bash ./configure`，报错：

```
configure: The C compiler (located as /usr/bin/gcc) does not seem to be the required GCC compiler.
configure: The result from running with --version was: "Configured with: --prefix=/Applications/Xcode.app/Contents/Developer/usr --with-gxx-include-dir=/usr/include/c++/4.2.1"
configure: error: GCC compiler is required. Try setting --with-tools-dir.
```

参考

- [Building OpenJDK 8 on Mac OS X Mavericks][Building OpenJDK 8 on Mac OS X Mavericks]
- [[JDK-8025275] JDK 8 build fails in configure phase on Mac (says not the required gcc) - Java Bug System][JDK 8 build fails in configure phase on Mac (says not the required gcc) - Java Bug System]

这个问题是因为Xcode 5以后使用clang替代了gcc，而JDK目前不支持clang编译，所以。。。那试试JDK8u

```
hg clone http://hg.openjdk.java.net/jdk8u/jdk8u/
bash get_source.sh
```

执行`bash ./configure`，报错：

```
configure: error: Xcode 4 is required to build JDK 8, the version found was 8.1. Use --with-xcode-path to specify the location of Xcode 4 or make Xcode 4 active by using xcode-select.
```

真是日了狗了。。。

---

回过头来安装老的JDK来编译JDK7。涉及到如何在Mac上安装多个版本的JDK。

- [Install Multiple Java Versions on Mac](http://davidcai.github.io/blog/posts/install-multiple-jdk-on-mac/)
- [Papo's log: Multiple Java JDK(s), on your MacOSX environment](http://javapapo.blogspot.com/2013/02/multiple-java-jdks-on-your-macosx.html)
- [Multiple JDK in Mac OSX 10.10 Yosemite | Abe Tobing's Blog](http://abetobing.com/blog/multiple-jdk-mac-osx-10-10-yosemite-88.html)

```
brew tap caskroom/versions
brew cask install java7
```

然后在你的.bashrc中添加：

```
export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8)
export JAVA_7_HOME=$(/usr/libexec/java_home -v1.7)
export JAVA_6_HOME=$(/usr/libexec/java_home -v1.6)
 
alias java6='export JAVA_HOME=$JAVA_6_HOME'
alias java7='export JAVA_HOME=$JAVA_7_HOME'
alias java8='export JAVA_HOME=$JAVA_8_HOME'
 
#default java8
export JAVA_HOME=$JAVA_8_HOME
```

然后吧my-build.sh中的Bootstrap JDK版本换成1.7的：

```
export ALT_BOOTDIR="/Library/Java/JavaVirtualMachines/jdk1.7.0_80.jdk/Contents/Home"
```

然后编译：`source my-build.sh && make`

报错如下：

```
/Users/mazhibin/project/jdk/openjdk/build/macosx-x86_64/corba/gensrc/org/omg/PortableServer/AdapterActivatorOperations.java:6: 错误: 编码ascii的不可映射字符
* ���IDL-to-Java ��������� (���������), ������ "3.2"������
```

查看对应的文件：

```
package org.omg.PortableServer;


/**
* org/omg/PortableServer/AdapterActivator.java .
* 由IDL-to-Java 编译器 (可移植), 版本 "3.2"生成
* 从../../../../src/share/classes/org/omg/PortableServer/poa.idl
* 2016年12月29日 星期四 上午08时24分54秒 CST
*/


/**
* An adapter activator supplies a POA with the ability▫
* to create child POAs on demand, as a side-effect of▫
* receiving a request that names the child POA▫
* (or one of its children), or when find_POA is called▫
* with an activate parameter value of TRUE.
*/
public interface AdapterActivator extends AdapterActivatorOperations, org.omg.CORBA.Object, org.omg.CORBA.portable.IDLEntity▫
{
} // interface AdapterActivator
```

怎么会生成中文了呢。。。

这个邮件列表是一模一样的问题：[Encoding problem when building](http://mail.openjdk.java.net/pipermail/build-dev/2013-January/007798.html)

TODO
[第一章 Mac os下编译openJDK 7 - 菜鸟很菜的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/j754379117/article/details/53695426)
[自己动手编译JDK并单步调试hotspot（Mac）](http://blog.wuzx.me/archives/638)

错误：

```
clang: error: unknown argument: '-fpch-deps'
```


## 参考资料
- 《深入理解Java虚拟机》
- [Mac OS下编译openJDK碰到的问题][Mac OS下编译openJDK碰到的问题]
- [Building OpenJDK 8 on Mac OS X Mavericks][Building OpenJDK 8 on Mac OS X Mavericks]

[OpenJDK 7 Updates Project Source Releases]: https://jdk7.java.net/source.html
[NetBeans IDE 下载]: http://netbeans.org/downloads/
[Mac OS下编译openJDK碰到的问题]: http://www.luyuncheng.com/?p=376
[编译OpenJDK出现问题]: http://bbs.csdn.net/topics/391875994
[Building OpenJDK 8 on Mac OS X Mavericks]: http://gvsmirnov.ru/blog/tech/2014/02/07/building-openjdk-8-on-osx-maverick.html
[JDK 8 build fails in configure phase on Mac (says not the required gcc) - Java Bug System]: https://bugs.openjdk.java.net/browse/JDK-8025275


