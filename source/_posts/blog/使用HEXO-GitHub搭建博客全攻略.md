---
title: 使用HEXO+GitHub搭建博客全攻略
date: 2016-01-21 17:28:05
tags: blog
toc: true
---

木杉的博客V3版迟迟没法动手。因为前缀项目Atom-note还没眉目呢。。。

前一阵使用CSDN写博客。他终于提供了跟得上时代的markdown编辑器了。。。（其他的老牌博客网站就不提了，写作体验，0分）。虽然他的编辑器声称有本地缓存。但是当我修改一篇已经发布的文章时，不小心关闭了浏览器，然后这篇文章就没了，没了，了

所以痛定思痛。用HEXO+GitHub这个有名方案试一发。

# 新建GitHub Pages项目
GitHub Pages可以使用使用GitHub上的仓库作为网站数据，很是方便，限制就是只能做静态网站。

1. 新建一个username.github.io的仓库。
2. git clone https://github.com/username/username.github.io
3. cd username.github.io
4. echo "Hello World" > index.html
5. git add --all
6. git commit -m "Initial commit"
7. git push -u origin master
8. 访问http://username.github.io

如果你看到hello world。说明GitHub Pages仓库搞定了。

# HEXO
## 安装HEXO

    npm install -g hexo-cli
    
## 新建博客项目

    hexo init <folder>
    cd <folder>
    npm install

## 修改配置
新建好工程后，编译一下配置文件`_config.yml`。HEXO的配置文件按照类型划分为几块。Site是最基本的一块配置。

```
# Site
title: 网站的标题
subtitle: 网站的副标题
description: 网站的描述
author: 作者
language: 网站的语言。默认为en。
timezone: 网站的时区。默认使用系统的时区。
```

一开始我们只要修改这一块的配置就够了。

## 新建文章

    hexo new [layout] <title>

layout是可选参数，选择不同的layout，新建的文章会新建在不同的目录。默认有三个layout：

| Layout | 新建文章所在的目录 |
|---|---|
| post    | source/_posts |
| page    | source |
| draft  | source/_drafts |

draft这个layout是草稿的意思，默认不会发布到网站上的。如果你的草稿完成了，可以使用命令：

    hexo publish [layout] <title>

发布草稿到`_post`目录

## 启动hexo-server

    hexo server

访问`http://localhost:4000`就可以看到你的博客网站了！

## 生成静态文件

    hexo generate

hexo会在根目录下生成一个public文件夹。里面是生成的静态网站所需要的全部文件。我们把他部署到github pages上就能实现对外访问了。

## 部署到github
不需要我们手动部署，hexo包含部署功能。只要一个命令就能部署：

    hexo deploy

在第一次部署前，不要配置一下，在`NexT`中：

```
# Deployment
## Docs: https://hexo.io/docs/deployment.html
deploy:
  type: git
  repo: <repository url>
```

默认配置的type为空，这里我们改成git。repo写github pages的仓库地址。

然后安装git部署插件：

    npm install hexo-deployer-git --save

运行deploy，你就可以看到你的博客啦！

## 命令简写
hexo提供了一套命令简写，方便使用：

```
hexo n = hexo new
hexo p = hexo publish
hexo g = hexo generate
hexo s = hexo server
hexo d = hexo deploy
```

## 更换皮肤
hexo最吸引人的一点就是有大量漂亮的皮肤，而且使用非常的简单。我们这一换一个非常有名的`NexT`皮肤试试。

```
cd your-hexo-site
git clone https://github.com/iissnan/hexo-theme-next themes/next
```

修改hexo的配置文件，把`theme: landscape`把`theme: next`

然后。已经可以了。。。是不是简单到没朋友。

还有一款`yilia`，也是国人开发，也非常不错。

    git clone https://github.com/litten/hexo-theme-yilia.git themes/yilia
    
## 皮肤的详细配置
我最终使用的是`yilia`，所以来说说怎么配置这款皮肤。皮肤自己的配置在`themes/yilia/_config.yml`中。

我新建了`hexo-project/source/public/image`目录。hexo在编译时，会把source目录下非`_`开头的文件夹直接复制到public目录下，也就是网站根目录下。我打算把共有的资源文件都放在`public`目录下，然后共有的图片文件都放在`public/image`下。头像也就可以放在这个目录下。然后修改`themes/yilia/_config.yml`

```
avatar: /public/image/you-avatar.png
```

还有就是JiaThis分享按钮和多说评论框。

// TODO 这里发现了`yilia`的一些问题。以后来详细说明

## 绑定域名

// TODO 目前还没考虑好是否绑定域名。日后再说吧。

## 技巧
### 显示摘要
默认首页会把文章的全部展示出来，这样信息太多了不太好。如何显示摘要呢？hexo默认带了这个功能的，只要在文章中插入`<!-- more -->`，之前的内容就会被作为摘要展示了。

### 开启RSS功能

    $ npm install hexo-generator-feed --save

编辑hexo/_config.yml，添加如下代码：
    
    rss: /atom.xml #rss地址  默认即可

## 杂项
2016年06月14日
换成了maupassant-hexo这个主题，感觉很不错！

# 参考连接
- [GitHub Pages - Websites for you and your projects, hosted directly from your GitHub repository. Just edit, push, and your changes are live.](https://pages.github.com/)
- [Documentation | Hexo](https://hexo.io/docs/)
- [有哪些好看的 Hexo 主题？ - GitHub - 知乎](http://www.zhihu.com/question/24422335)
- [NexT - an elegant theme for Hexo.](http://theme-next.iissnan.com/)
- [litten/hexo-theme-yilia: 一个简洁优雅的hexo主题 ; A simple and elegant theme for hexo.](https://github.com/litten/hexo-theme-yilia)
- [(1)hexo常用命令笔记 - 埋名 - SegmentFault](http://segmentfault.com/a/1190000002632530?utm_source=tuicool&utm_medium=referral)
- [Hexo 主题Light修改教程 - 简书](http://www.jianshu.com/p/70343b7c2fd3)