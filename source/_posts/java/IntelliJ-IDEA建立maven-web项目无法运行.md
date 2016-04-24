---
title: IntelliJ IDEA建立maven web项目无法运行
date: 2016-04-24 21:08:06
tags: java
---

参照网上使用idea来建立maven web项目的文章：

- [Intellij IDEA创建Maven Web项目 - 蛙牛的个人页面 - 开源中国社区](http://my.oschina.net/lujianing/blog/266172)
- [idea14使用maven创建web工程 - Event driven - ITeye技术网站](http://geeksun.iteye.com/blog/2179658)

但是到了最后一步访问，tomcat总是提示404。崩溃。。。。

后来我意识到是不是我的操作步骤和他们的有些不同而导致的。不同之处是，他们直接新建一个webapp，而我是建立了一个webapp的module。

![](img/java/idea-maven-webapp/1.png)

其中learn-servlet是父项目，learn-servlet-baisc是子项目。建立子项目有什么需要注意的地方么？于是我建立了一个普通maven webapp。

![](img/java/idea-maven-webapp/2.png)

还真的有区别。。。后者的webapp目录里面有个 小 地 球 ！这是什么鬼。。。

直觉告诉我，ide对目录进行渲染了，说明他对这个目录有一些特殊处理。然后我对比了两个项目运行后的目录：

![](img/java/idea-maven-webapp/3.png)

![](img/java/idea-maven-webapp/4.png)

作为module的项目，并没有吧webapp目录输出到target目录中！所以整个项目就只有一个META-INF目录，没有任何实质的内容，所以就404了！

作为IDE，是不会管里用的是maven还是ant什么的，他们有他们自己的一套，怎么编译，部署等。一般情况下，新建或者导入maven工程，idea都会正确的识别目录结构，比如什么是代码目录，什么是测试目录，什么是资源目录，什么是输出目录。然后编译时，idea就会编译代码目录，复制资源到输出目录。IDE能正常运行仰仗这种对应关系。

目前看来，新建webapp类型的maven module时，idea的识别maven工程的功能没有正常运行，导致他没有识别webapp目录。那我们就自己添加吧。打开正常的项目的项目设置：

![](img/java/idea-maven-webapp/5.png)

可以看到其添加了一个Web的framework，其指定了web.xml文件的路径，一级web资源目录的路径（也就是webapp目录的路径）。我们依样画葫芦地在module项目中添加：

![](img/java/idea-maven-webapp/6.png)

注意，默认添加后的路径并不正确，learn-servlet/learn-servlet-basic/web/WEB-INF/web.xml，需要改成：learn-servlet/learn-servlet-basic/src/main/webapp/WEB-INF/web.xml，也就是maven项目中的那个。

添加完后webapp目录icon中就出现地图啦！

![](img/java/idea-maven-webapp/7.png)

运行，成功！


