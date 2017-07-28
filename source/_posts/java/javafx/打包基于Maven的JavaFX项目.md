---
title: 打包基于Maven的JavaFX项目
date: 2017-07-28 10:20:51
categories: [Java]
tags: [java,javafx]
---

用JavaFx写了个小工具，但是如果只能自己运行那就太不好了。JavaFX官方有一篇打包文档，[Deploying JavaFX Applications: About This Guide | JavaFX 2 Tutorials and Documentation](http://docs.oracle.com/javafx/2/deployment/jfxpub-deployment.htm)，看着非常麻烦，加上我的项目是基于maven的，也不知道官方的方法能不能行。

好在有一个JavaFX的maven插件，可以非常方便的进行打包，插件项目地址[javafx-maven-plugin/javafx-maven-plugin: Maven plugin for JavaFX](https://github.com/javafx-maven-plugin/javafx-maven-plugin)

使用这个插件，只要两个配置项就行：

```xml
<plugin>
    <groupId>com.zenjava</groupId>
    <artifactId>javafx-maven-plugin</artifactId>
    <version>8.8.3</version>
    <configuration>
        <vendor>YourCompany</vendor>
        <mainClass>your.package.with.Launcher</mainClass>
    </configuration>
</plugin>
```

指定vendor和mainClass，然后执行`mvn jfx:native`，就会在`target/jfx/native`下生成你的应用了！带可执行文件！带jre运行环境！打包发给别人就行了。

因为需要携带jre，所以导致一个简简单单的应用都有接近200M。。。。

## 参考资料
- [javafx-maven-plugin/javafx-maven-plugin: Maven plugin for JavaFX](https://github.com/javafx-maven-plugin/javafx-maven-plugin)
