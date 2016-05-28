---
title: 在IDEA中运行调试Tomcat
date: 2016-05-27 17:51:00
tags: java
---

git clone https://github.com/apache/tomcat.git
cd tomcat
cp build.properties.default build.properties

# ----- Proxy setup -----
proxy.host=proxy.domain
proxy.port=7777
proxy.use=on


ant ide-eclipse

修改classpath.xml

吧ANT_HOME，TOMCAT_LIBS_BASE替换为具体的路径

/Users/mazhibin/tomcat-build-libs
/usr/local/Cellar/ant/1.9.6/libexec

idea导入，提示jdk错误
Module tomcat-9.0.x : invalid item '< JavaSE-1.8 >' in the dependencies list

图片

项目结构：
Project Structure-Modules
切换jdk



[Apache Tomcat 8 (8.0.35) - Building Tomcat](http://tomcat.apache.org/tomcat-8.0-doc/building.html)