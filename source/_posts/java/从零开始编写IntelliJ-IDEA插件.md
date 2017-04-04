---
title: 从零开始编写IntelliJ IDEA插件
date: 2017-04-01 10:14:10
categories: [Java]
tags: [java,idea]
---

写Java代码的时候，经常会涉及到重复性的操作，这个时候就会想要是有这样一个插件就好了，如果是大家都会遇到的场景，IDE或许已经提供了，再不然也有可能有人编写了相关的插件。要是这个操作是你们的编码环境特有的，那就只能自己写工具了。所以这里来学学如何编写IDEA插件，让自己的编程环境更加强大，更好的进行装逼。

<!--more-->

## 开发环境
开发IDEA插件有以下这些依赖：

- IntelliJ IDEA Community Edition 
- IntelliJ IDEA Community Edition 源码
- Plugin DevKit 插件
- IntelliJ Platform SDK

### 安装IntelliJ IDEA Community Edition
你可能已经安装了Ultimate版本，但是你还是需要安装IDEA的社区版本。因为商业版是闭源的，所以在调试时无法调试核心代码。

### 下载IntelliJ IDEA Community Edition源码
社区版的安装包里是不包含源码的，所以我们需要手动从github上clone一份：

```
git clone --depth 1 git://git.jetbrains.org/idea/community.git idea
```

关于从源码运行IDEA的方法参考：[Check Out And Build Community Edition](http://www.jetbrains.org/intellij/sdk/docs/basics/checkout_and_build_community.html)

### 添加IDEA jdk
虽然不知道原因，但是根据[Check Out And Build Community Edition](http://www.jetbrains.org/intellij/sdk/docs/basics/checkout_and_build_community.html)，我们需要建立一个`IDEA jdk`来运行插件：

![](/img/java/idea/14910140405419/14910447672307.jpg)￼

除非你在Mac上使用官方JDK，否则你需要手动添加`/lib/tools.jar`到classpath中。

### 配置IntelliJ Platform SDK
打开`File | Project Structure`新建一个`IntelliJ Platform SDK`：

![](/img/java/idea/14910140405419/14910140718316.jpg)￼

Java SDK选择我们刚刚建立的`IDEA jdk`：

![](/img/java/idea/14910140405419/14910449400889.jpg)￼

然后我们可以把下载的IDEA社区版源码添加到源码路径中，这样在调试时，就可以调试IDEA自身的代码了：

![](/img/java/idea/14910140405419/14910450172506.jpg)￼

![](/img/java/idea/14910140405419/14910450845885.jpg)￼

## 第一个插件
我们来编写一个最简单的插件来学习编写一个插件的完整步骤。

### 新建工程
选择`IntellJ Platform Plugin`，然后Project SDK指定刚刚新建的plugin sdk：

![](/img/java/idea/14910140405419/14910451487756.jpg)￼

新建的插件项目：

![](/img/java/idea/14910140405419/14913163331150.jpg)￼

插件根目录下有两个目录`src`和`resources`。`src`是插件代码目录，`resource`是插件资源目录，其中`META-INF/plugin.xml`是插件的描述文件，就像Java web项目的`web.xml`一样。

plugin.xml默认的内容如下：

```xml
<idea-plugin>
  <id>com.your.company.unique.plugin.id</id>
  <name>Plugin display name here</name>
  <version>1.0</version>
  <vendor email="support@yourcompany.com" url="http://www.yourcompany.com">YourCompany</vendor>

  <description><![CDATA[
      Enter short description for your plugin here.<br>
      <em>most HTML tags may be used</em>
    ]]></description>

  <change-notes><![CDATA[
      Add change notes here.<br>
      <em>most HTML tags may be used</em>
    ]]>
  </change-notes>

  <!-- please see http://www.jetbrains.org/intellij/sdk/docs/basics/getting_started/build_number_ranges.html for description -->
  <idea-version since-build="145.0"/>

  <!-- please see http://www.jetbrains.org/intellij/sdk/docs/basics/getting_started/plugin_compatibility.html
       on how to target different products -->
  <!-- uncomment to enable plugin in all products
  <depends>com.intellij.modules.lang</depends>
  -->

  <extensions defaultExtensionNs="com.intellij">
    <!-- Add your extensions here -->
  </extensions>

  <actions>
    <!-- Add your actions here -->
  </actions>

</idea-plugin>
```

### 新建一个Action
插件扩展IDEA最常见的方式就是在菜单栏或者工具栏中添加菜单项，用户通过点击菜单项来触发插件功能。IDEA提供了`AnAction`类，这个类有一个虚方法`actionPerformed`，这个方法会在每次菜单被点击时调用。

新建一个自定义的Action有两个步骤：

1. 继承`AnAction`类，在`actionPerformed`方法中实现插件逻辑
2. 注册action，有两种方式，通过代码注册和通过`plugin.xml`注册

我们先写一个简单的Action类：

```java
public class TextBoxes extends AnAction {
    // 如果通过Java代码来注册，这个构造函数会被调用，传给父类的字符串会被作为菜单项的名称
    // 如果你通过plugin.xml来注册，可以忽略这个构造函数
    public TextBoxes() {
        // 设置菜单项名称
        super("Text _Boxes");
        // 还可以设置菜单项名称，描述，图标
        // super("Text _Boxes","Item description",IconLoader.getIcon("/Mypackage/icon.png"));
    }
 
    public void actionPerformed(AnActionEvent event) {
        Project project = event.getData(PlatformDataKeys.PROJECT);
        String txt= Messages.showInputDialog(project, "What is your name?", "Input your name", Messages.getQuestionIcon());
        Messages.showMessageDialog(project, "Hello, " + txt + "!\n I am glad to see you.", "Information", Messages.getInformationIcon());
    }
}
```

然后我们在`plugin.xml`中注册这个Action：

```xml
<actions>
  <group id="MyPlugin.SampleMenu" text="_Sample Menu" description="Sample menu">
    <add-to-group group-id="MainMenu" anchor="last"  />
       <action id="Myplugin.Textboxes" class="Mypackage.TextBoxes" text="Text _Boxes" description="A test menu item" />
  </group>
</actions>
```

这里我们新建了一个菜单组，其中text字符串的下划线表示这个字母作为快捷键。这个菜单显示的效果如下：

![](/img/java/idea/14910140405419/14913176212218.jpg)￼

除了手动新建Action，IDEA还提供了快速新建的方法，在代码目录上点击新建，可以看到Action：

![](/img/java/idea/14910140405419/14913178262565.jpg)￼

可以在这个面板中填写你要新建的Action信息，IDEA会帮你新建类，还有在plugin.xml中帮你注册：

![](/img/java/idea/14910140405419/14913180035888.jpg)￼

### 运行插件
运行插件特别简单，和运行普通Java代码一样，点击运行或者调试的按钮，就会启动一个新的IDEA实例，这个实例中插件是生效的。

点击Text Boxes就可以看到插件的效果了。

## 参考资料
- [Setting Up a Development Environment](http://www.jetbrains.org/intellij/sdk/docs/basics/getting_started/setting_up_environment.html)
- [How to make an IntelliJ IDEA plugin in less than 30 minutes](http://bjorn.tipling.com/how-to-make-an-intellij-idea-plugin-in-30-minutes)

