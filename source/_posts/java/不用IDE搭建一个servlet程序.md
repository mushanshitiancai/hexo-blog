---
title: 不用IDE搭建一个servlet程序
date: 2016-03-18 22:33:47
categories: [JAVA]
tags: java
---

虽然可以使用eclispe或者intellijIDEA快速搭建一个java servlet程序，但是还是值得纯手动搭建一个的，这有助于理解java web工程的基本结构。

## 环境
- mac
- homebrew
- jdk8

## 安装tomcat
可以使用homebrew快速安装tomcat：

    $ brew install tomcat

homebrew默认把程序安装在`/usr/local/Cellar`中，所以你可以在`/usr/local/Cellar/tomcat/8.0.28`中找到tomcat的相关文件。

操作tomcat使用的是`/usr/local/Cellar/tomcat/8.0.28/bin/catalina`这个脚本。homebrew在安装的时候一般都会把软件的可执行文件放在`/usr/local/bin`下，`catalina`也不例外：

```
$ ll /usr/local/bin/catalina
lrwxr-xr-x  1 mazhibin  admin    36B  3  7 23:27 /usr/local/bin/catalina -> ../Cellar/tomcat/8.0.28/bin/catalina
```

启动tomcat服务：

    $ catalina start

停止：

    $ catalina stop

### chrome打不开localhost:8080的问题
启动tomcat服务后，用chrome打开http://localhost:8080，提示`ERR_EMPTY_RESPONSE`。但是Safari没问题。。。

经排查，这是因为我使用ss梯子，并且选择了"全局模式"，导致访问localhost这个域名出错了。关闭ss或者改为自动代理模式就没问题了。

## servlet程序的目录结构
servlet规定了程序的目录结构：

```
testapp
├── WEB-INF
│   ├── classes
│   └── lib
└── index.jsp
```

`testapp`是程序目录。对应着网站的跟目录。把应用部署到tomcat，只需要把应用目录放到tomcat的`webapps`目录下即可。

`WEB-INF`是一个特殊目录，他受到容器的保护，用户是无法访问到其中的内容的。`WEB-INF/classes`目录用来放程序的class文件。`WEB-INF/lib`目录用来放程序依赖的第三方jar。

如果只有静态文件或者jsp文件，那么就不需要`WEB-INF`目录。静态文件和jsp文件直接放应用根目录底下即可。

在`index.jsp`中写如"Hello Word!"，部署应用到tomcat，然后启动tomcat，访问http://localhost:8080就能看到"Hello Word!"了。

## 写一个servlet
在`WEB-INF/classes`下新建`MyServlet.java`：

```
import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.Servlet;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebServlet;

@WebServlet(name="MyServlet",urlPatterns={"/my"})
public class MyServlet implements Servlet{
    private ServletConfig config;
    
    @Override
    public void destroy() {
    }

    @Override
    public ServletConfig getServletConfig() {
        return config;
    }

    @Override
    public String getServletInfo() {
        return "My Servlet";
    }

    @Override
    public void init(ServletConfig config) throws ServletException {
        this.config = config;
    }

    @Override
    public void service(ServletRequest request, ServletResponse response) throws ServletException, IOException {
        String servletName = config.getServletName();
        response.setContentType("text/html; charset=utf-8");
        PrintWriter writer = response.getWriter();
        writer.print("<html><head></head><body>Hello from"+servletName+"。你好</body></html>");
    }
    
}
```

然后编译java为class文件，重启服务器：

```
$ javac -classpath /usr/local/Cellar/tomcat/8.0.28/libexec/lib/servlet-api.jar MyServlet.java
$ catalina stop && catalina start
```

然后访问http://localhost:8080/demoapp/my，就可以看到这个servlet的输出了。

## 总结
都说Java开发难。我主要是因为大家一上手就来ssh啥的，能不难么。其实Java web的核心servlet是简单的，和cgi相比差不离多少。Javaee会如此复杂，是因为Javaee定义了很多标准，而PHP世界里没有这些标准，大家都是各自实现自己需要的功能的。

所以学号java web还是得打好基础，理解投了servlet，jsp等基础技术，对于之后理解ssh等框架是很有帮助的。

## 参考资料
- 《servlet和jsp学习指南》
-  [Craic Computing Tech Tips: Installing Apache tomcat on Mac OS X Lion using homebrew](http://craiccomputing.blogspot.com/2012/07/installing-apache-tomcat-on-mac-os-x.html)
