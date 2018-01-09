---
title: 'GraphicsMagick笔记-gm convert: Unable to read font'
date: 2018-01-09 19:33:20
categories:
tags: [gm,graphicsmagick]
---

环境：Windows10，GraphicsMagick-1.3.18-Q8

执行`gm convert -draw "text 100,100 hello" input.jpg output.png`画文字的时候报错：

```
gm convert: Unable to read font (n019003l.pfb) [No such file or directory]
```

<!--more-->

这是因为GraphicsMagick在画文字的时候依赖Ghostscript Fonts。

根据官网文档：http://www.graphicsmagick.org/INSTALL-windows.html#prerequisites，还需要安装 Ghostscript和Ghostscript Fonts。注意，如果你安装的是64位的GraphicsMagick，那么也需要安装64位的Ghostscript。

问题在Ghostscript Fonts如何安装，官网没有给出安装方法。

GraphicsMagick安装目录下的type-ghostscript.mgk文件配置了这些字体文件：

```xml
  <type
    name="AvantGarde-Book"
    fullname="AvantGarde Book"
    family="AvantGarde"
    foundry="URW"
    weight="400"
    style="normal"
    stretch="normal"
    format="type1"
    metrics="@ghostscript_font_dir@a010013l.afm"
    glyphs="@ghostscript_font_dir@a010013l.pfb"
    />
```

可以看到，metrics和glyphs属性指定了对应的字体文件的地址，不过使用了占位符`@ghostscript_font_dir@`。

网上也没有查到资料说哪里才是`@ghostscript_font_dir@`，或者什么参数可以指定这个目录的位置。比较常见的解决方案是修改`@ghostscript_font_dir@`为具体的字体文件所在目录的路径。

这个时候，我想到了侯捷老师的一句话，“源码面前，了无秘密”。遂下载GraphicsMagick的源码来看看这个变量到底是如何获取的。

GraphicsMagick的源码托管在Mercurial上，可以下载TortoiseHg工具来把代码clone下来。

TortoiseHg下载地址：https://www.mercurial-scm.org/
项目clone地址：http://hg.code.sf.net/p/graphicsmagick/code

下载好代码，搜索一下`ghostscript_font_dir`，找到了`type.c`在操作这个占位符。然后找到具体的函数为`nt_base.c`的1`NTGhostscriptFonts`函数，其中有非常详细的注释：

```
Search path used by GPL Ghostscript 9.10 (2013-08-30):
  C:\Program Files\gs\gs9.10\bin ; C:\Program Files\gs\gs9.10\lib ;
  C:\Program Files\gs\gs9.10\fonts ; %rom%Resource/Init/ ; %rom%lib/ ;
  c:/gs/gs9.10/Resource/Init ; c:/gs/gs9.10/lib ;
  c:/gs/gs9.10/Resource/Font ; c:/gs/fonts
```

也就是说GM会在这些检查这些目录是否存在。所以我们只要吧fonts目录拷贝到对应的路径下就行了。这里我把代码拷贝到`c:/gs/fonts`。再次运行发现还是不行，考虑到可能和版本有关系，因为我看的代码是新版本的。

ftp://ftp.graphicsmagick.org/pub/GraphicsMagick/1.3/这个网址可以看到所有1.3版本的GM，找到我用的1.3.18的版本是2013/3/10 上午8:00:00发布的，而注释是在2013-08-30写的。。。。而1.3.19就是在2013/12/31发布的，所以只要是大于等于1.3.19的应该就可以了。

安装了个GraphicsMagick-1.3.23-Q8，成功！

## 参考资料
- [node - 如何安装graphicsmagick和ghostscript font? - SegmentFault](https://segmentfault.com/q/1010000011372490)