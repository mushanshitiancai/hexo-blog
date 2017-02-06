---
title: 调试doclet
date: 2017-02-06 19:29:53
categories: [Java]
tags: [java,doclet]
---

之前在编写doclet时，都是使用`mvn javadoc:javadoc`来运行doclet的。这样运行doclet无法进行调试，使doclet开发起来非常痛苦。今天来研究下如何调试doclet。

<!--more-->

maven的javadoc插件是调用javadoc命令来生成文档的。在javadoc插件的配置添加一个参数：

```xml
<debug>true</debug>
```

这样在运行javadoc后，会在输出目录保留插件调用的命令脚本，已经传入的参数，是三个文件：

```
javadoc.sh
options
packages
```

javadoc.sh的内容只有一行：

```
/Library/Java/JavaVirtualMachines/jdk1.8.0_60.jdk/Contents/Home/bin/javadoc @options @packages
```

可以看出javadoc插件调用的就是JAVA_HOME下的javadoc命令。参数在options文件中，需要处理的代码的包定义在packages文件中。

根据资料得知，javadoc除了提供脚本工具，还提供了代码入口，供调试和工具调用。代码入口的类是`com.sun.tools.javadoc.Main`。使用这个入口运行javadoc，结合maven javadoc插件生成的参数文件，我们就可以调试了！

```java
public static void main(String[] args) {
    String optionsPath = "/Users/mazhibin/project/apidocs/options";
    String packagesPath = "/Users/mazhibin/project/apidocs/packages";

    String[] docArgs = new String[]{"@" + optionsPath, "@" + packagesPath};
    com.sun.tools.javadoc.Main.execute(docArgs);
}
```

然后就可以愉快地断点调试啦😊

## javadoc命令文档

我把javadoc man文档的一部分复制出来了，这里说明了为什么可以使用`@options @packages`这样两个参数。

```
Command Line Argument Files
To shorten or simplify the javadoc command line, you can specify one or more files that themselves contain arguments to the
javadoc command (except -J options).  This enables you to create javadoc commands of any length on any operating system.

An  argument  file can include Javadoc options, source filenames and package names in any combination, or just arguments to
Javadoc options. The arguments within a file can be space-separated or newline-separated. Filenames within an argument file
are  relative to the current directory, not the location of the argument file. Wildcards (*) are not allowed in these lists
(such as for specifying *.java).  Use of the '@' character to recursively interpret files is not supported. The -J  options
are not supported because they are passed to the launcher, which does not support argument files.

When  executing  javadoc,  pass  in  the  path  and name of each argument file with the '@' leading character. When javadoc
encounters an argument beginning with the character '@', it expands the contents of that file in the argument list.

Example - Single Arg File

You could use a single argument file named "argfile" to hold all Javadoc arguments:

        % javadoc @argfile

This argument file could contain the contents of both files shown in the next example.

Example - Two Arg Files

You can create two argument files - one for the Javadoc options and the other for the package names  or  source  filenames:
(Notice the following lists have no line-continuation characters.)

Create a file named "options" containing:

        -d docs-filelist
        -use
        -splitindex
        -windowtitle 'Java 2 Platform v1.3 API Specification'
        -doctitle 'Java<sup><font size="-2">TM</font></sup> 2\
                        Platform v1.4 API Specification'
        -header '<b>Java 2 Platform </b><br><font size="-1">v1.4</font>'
        -bottom 'Copyright 1993-2000 Sun Microsystems, Inc. All Rights Reserved.'
        -group "Core Packages" "java.*"
        -overview /java/pubs/ws/1.3/src/share/classes/overview-core.html
        -sourcepath /java/pubs/ws/1.3/src/share/classes

Create a file named "packages" containing:

        com.mypackage1
        com.mypackage2
        com.mypackage3

You would then run javadoc with:

        % javadoc @options @packages

Example - Arg Files with Paths

The  argument  files  can have paths, but any filenames inside the files are relative to the current working directory (not
path1 or path2):

        % javadoc @path1/options @path2/packages

Examples - Option Arguments

Here's an example of saving just an argument to a javadoc option in an argument file.  We'll use the -bottom option,  since
it can have a lengthy argument. You could create a file named "bottom" containing its text argument:

Submit  a  bug  or  feature</a><br><br>Java  is a trademark or registered trademark of Sun Microsystems, Inc. in the US and
other countries.<br>Copyright 1993-2000 Sun Microsystems, Inc. 901  San  Antonio  Road,<br>Palo  Alto,  California,  94303,
U.S.A.  All Rights Reserved.</font>'

The run the Javadoc tool with:

        % javadoc -bottom @bottom @packages

Or you could include the -bottom option at the start of the argument file, and then just run it as:

        % javadoc @bottom @packages
```

### 参考资料
- [自定义java Doclet的调试](http://m.blog.csdn.net/article/details?id=8694563)
- [Apache Maven Javadoc Plugin – javadoc:javadoc](https://maven.apache.org/plugins/maven-javadoc-plugin/javadoc-mojo.html)