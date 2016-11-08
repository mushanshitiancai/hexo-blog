---
title: 编写jEdit宏
date: 2016-11-08 16:36:45
categories:
tags: [tools]
---

场景是这样的，我需要梳理一个项目的代码，我面对很多这样的函数签名：

```
L2CircleEntityDataCacheItem GetOneCircle( int circleId );

List<L2CircleEntityDataCacheItem> GetMultiCircles( IEnumerable<int> circleIdList );

List<L2CircleEntityDataCacheItem> GetAllCircles();
```

我在写笔记的时候，希望只记录函数名，参数和返回值这种细节我就不记录了。问题来了，我要如何高效的获取这些代码片段的函数名呢？

方法自然使用正则来提取，我可以把代码片段粘贴到sublime中，然后使用正则来替换。可以使用`.*\b+(\w+)\(.*`这个正则来匹配所有的函数名（这个不是一个好正则，但是能用），然后在匹配全部，然后点击全选匹配的部分，然后就可以复制全部的函数名了。

这个过程还是有些痛苦的，尤其是如果你每次都要执行这个固定的步骤。当然，这个需求写一个sublime插件就可以轻松解决了，但是这么简单的任务，还需要写一个完整的插件，太痛苦了。

这个时候，我想到了jEdit。jEdit是一个基于Java的文本编辑器。应该是一个很冷门的编辑器了，因为基于Java，的确不敏捷也不漂亮，所以我当初试了一下也没管了。但是我记得他有个宏功能，可以使用Java来编写宏。这种轻量级的插件，正是我现在想要的。

先来看看jEdit长啥样：

![](/img/tools/jedit.png)

jEdit的宏基于[BeanShell][BeanShell]，BeanShell是一个Java的脚本引擎，可以使用Java来写脚本，所以你可以使用Java来写和jEdit互操作的脚本，也就是宏。jEdit官方提供了编写宏的文档[Writing Macros][Writing Macros]，同时jEdit也自带了一些宏，很有学习意义。

新建宏的入口是Macros -> New Macros。编写并保存，在Macros中就会出现你编写宏了，点击就可以运行，真的还是非常方便。而且，可以更进一步地把宏嵌入到右键菜单中，更方便使用，这个大家自己探索吧。

好，我们回过头来说说如何使用宏来实现提取函数签名的功能，代码很简单：

```
import java.util.regex.Matcher;
import java.util.regex.Pattern;

void getMethodName()
{
    selectionString = textArea.getSelectedText();
    if(selectionString == null){
        return;
    }
    
    StringBuilder sb = new StringBuilder();
    Pattern getMethodPattern = Pattern.compile(".*\\b+(\\w+)\\(.*");
    Matcher matcher = getMethodPattern.matcher(selectionString);
    while(matcher.find()){
        String methodName = matcher.group(1);
        sb.append(methodName + "\n");
    }
    
    selections = textArea.getSelectedLines();
    if(selections.length == 0){
        selections = new int [] {textArea.getCaretLine()};
    }
    start = textArea.getLineStartOffset(selections[0]);
    stop = textArea.getLineEndOffset(selections[selections.length-1]);
    
    buffer.insert(stop-1, "\n"+sb.toString());
}

getMethodName();
```

在脚本中，jEdit自动引入了一些包：

```
java.awt
java.awt.event
java.net
java.util
java.io
java.lang
javax.swing
javax.swing.event
org.gjt.sp.jedit
org.gjt.sp.jedit.browser
org.gjt.sp.jedit.buffer
org.gjt.sp.jedit.gui
org.gjt.sp.jedit.help
org.gjt.sp.jedit.io
org.gjt.sp.jedit.msg
org.gjt.sp.jedit.options
org.gjt.sp.jedit.pluginmgr
org.gjt.sp.jedit.print
org.gjt.sp.jedit.search
org.gjt.sp.jedit.syntax
org.gjt.sp.jedit.textarea
org.gjt.sp.util
```

还引入了一些全局变量：

```
buffer - Buffer对象，对应着一个打开的文件

view - View对象，对应着当面活跃的编辑窗口

等价于：jEdit.getActiveView()

editPane - EditPane对象，对应着一个textArea和一个buffer切换器。一个view可以被分为多个editPane

等价于：view.getEditPane()

textArea - JEditTextArea对象，是用于显示当前buffer的组件

等价于：editPane.getTextArea()

wm - DockableWindowManager对象

等价于：view.getDockableWindowManager()

scriptPath - 当前执行脚本的绝对路径
```

我们使用这些变量就可以很方便的和jEdit交互。我的代码中，首先使用`textArea.getSelectedText()`获取当前编辑区中被选中的文本，如果有，则使用正则进行处理，提取全部的函数签名，然后插入到当前选区的下一行。

这里我使用Pattern来处理正则表达式，只需要简单的import他就行了，因为可以使用jdk中的包，所以你的宏可以很强大。

看看处理效果图：

![](/img/tools/jedit-macro.gif)

## 参考资料
- [Writing Macros][Writing Macros]
- [BeanShell][BeanShell]

[Writing Macros]: http://www.jedit.org/users-guide/writing-macros-part.html
[BeanShell]: https://github.com/beanshell/beanshell