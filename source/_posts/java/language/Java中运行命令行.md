---
title: Java中运行命令行
date: 2017-12-29 10:54:47
categories: [Java]
tags: [java]
---

很多时候Java的功能无法满足需求的时候，我们可以调用命令行或者第三方程序来实现对应的功能。Java提供了启动子进程并设置执行程序的能力，我们看一下怎么使用。

<!--more-->

```java
public static void main(String[] args) throws Exception {
    String command = "dir";

    // 新建进程并启动。不同的系统命令行执行方式不一样
    ProcessBuilder processBuilder;
    if (SystemUtils.IS_OS_WINDOWS) {
        processBuilder = new ProcessBuilder("cmd", "/c", command);
    } else {
        processBuilder = new ProcessBuilder("sh", "-c", command);
    }
    processBuilder.redirectErrorStream(true);  // 把标准错误输出流重定向到标准输出流
    final Process process = processBuilder.start();

    // 获取命令行的输出
    InputStream inputStream = process.getInputStream();
    try {
        System.out.println(IOUtils.toString(inputStream, System.getProperty("sun.jnu.encoding")));
    } catch (IOException e) {
        e.printStackTrace();
    }

    // 等待命令执行结束，获取退出码
    int exitCode = process.waitFor();
    System.out.println(exitCode);
}
```

`ProcessBuilder`类用于启动一个进程，进程类是`Process`，我们可以从`Process`类中获取子进程的标准输出，标准错误输出，同时我们使用标准输入可以向进程输入数据进行互动。上面的代码使用了`processBuilder.redirectErrorStream(true)`来把标准错误输出重定向到标准输出中，便于查看。

`SystemUtils`类是Apache Common的一个类，可以方便的判断当前的系统是哪个操作系统，可以精确到版本。windows和UNIX系统的执行命令的方式是不一样的，windows下使用cmd执行命令，UNIX系统使用bash执行命令，所以这里我们需要做区分。

同时，尤其是在windows下，国内的windows默认编码是GBK的，所以在和命令行进行交互的时候，需要设置好编码，否则会乱码。获取系统编码可以使用`System.getProperty("sun.jnu.encoding")`。根据网上资料`sun.jnu.encoding`获取的是系统文件名的编码，而一般我们使用的`file.encoding`获取的是文件内容的编码。即使在国内的windows环境下`file.encoding`也是UTF-8，因为JVM默认使用UTF-8作为文件内容字符的编码，而操作系统本身的编码就需要使用`sun.jnu.encoding`获取了。

## 参考资料
- [How to Run a Shell Command in Java | Baeldung](http://www.baeldung.com/run-shell-command-in-java)
- [【Java编程高级进阶】java 获取 string 字符串的编码详解 - 无知人生，记录点滴 - CSDN博客](http://blog.csdn.net/testcs_dn/article/details/53982619)