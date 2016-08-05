---
title: Quiver程序员笔记软件使用体验
date: 2016-08-03 10:01:49
categories:
tags: software
---

Quiver是一款宣传为专为程序员设计的笔记软件。这个宣传语还是比较吸引我的。下来试试看。

![](/img/software/quiver-app.png)

68块钱，不是很便宜哦。打开是这样的：

![](/img/software/quiver.png)

体验：

- 以cell为基本单位，有5种cell：text，code，markdown，latex，diagram
- 一篇文章中可以组合使用多种cell
- text cell和markdown cell在变化的时候会同时做格式转换
- 可以实时预览修改
- 内部存储中文章和笔记本都是通过UUID组织的


缺点：

- 因为可以组合cell，反而显得繁琐了，比如如果出现了多个cell，在编辑模式下甚至不能“全选”
- 编辑时，cell边框会高亮，会让你明显感觉到cell的存在，比较不爽
- text cell中没有“粘贴纯文本”这个功能（我个人觉得这个特性还是比较重要的）
- markdown cell中不能直接粘贴图片（这是一个不能没有的特性。。。）
- 不是纯文本组织，就算用git组织，也是一堆json

总结：

离我心目中的程序员笔记软件还是有距离，不过相比于其他笔记，已经能感受出来其为程序员设计的特性了。但是其使用起来的舒适感，以及文件组织形式都不太好。弃。

最后说一下quiver的文件组织形式：

```
➜  /Users/mazhibin/Documents/Quiver.qvlibrary  > tree
.
├── Inbox.qvnotebook
│   └── meta.json
├── Trash.qvnotebook
│   └── meta.json
└── Tutorial.qvnotebook
    ├── 3C175FCC-B306-4A71-9FBA-24BD1D9B448C.qvnote
    │   ├── content.json
    │   ├── meta.json
    │   └── resources
    │       ├── AD9CEC60-4B82-4488-A916-F12EFCB6C0D2.png
    │       └── AEAA2B10-5292-4524-9043-6E0DD1A69A8E.png
    ├── 8500A7F1-383D-43EA-B807-0EE6A2C730F7.qvnote
    │   ├── content.json
    │   ├── meta.json
    │   └── resources
    │       └── 0039E536-1343-4E82-908A-34B77B7ED2D9.png
    ├── 9686AA1A-A5E9-41FF-9260-C3E0D0E9D4CB.qvnote
    │   ├── content.json
    │   └── meta.json
    ├── 9FE3C3BB-8504-40D6-B91F-BEC4FA055617.qvnote
    │   ├── content.json
    │   └── meta.json
    ├── B59AC519-2A2C-4EC8-B701-E69F54F40A85.qvnote
    │   ├── content.json
    │   ├── meta.json
    │   └── resources
    │       ├── 1C3392AA-54E7-4EA3-A129-1C20F208B029.jpg
    │       └── F6E1CA4A-FA0B-4E45-9861-3E3FEB0DAF99.png
    ├── C1DF6E20-B3F3-4DEF-A3FF-B3033C69EA38.qvnote
    │   ├── content.json
    │   └── meta.json
    ├── C23160AA-78C5-459C-80E5-B0D24CB62B82.qvnote
    │   ├── content.json
    │   ├── meta.json
    │   └── resources
    │       └── 49D85B38-3A8F-4CCF-B07C-C89EB4A13BAF.png
    ├── C819626E-3BD3-4DDE-AF72-73C9C7B43428.qvnote
    │   ├── content.json
    │   ├── meta.json
    │   └── resources
    │       ├── 57BEDE28-70F2-4C67-9C13-621DF806AFD0.png
    │       ├── E3596D74-4437-499C-AF47-C56C409D0251.png
    │       └── E67B67BA-9D36-432F-818D-8838559CDFC0.png
    ├── D2A1CC36-CC97-4701-A895-EFC98EF47026.qvnote
    │   ├── content.json
    │   └── meta.json
    ├── ED3C96D1-AF37-4E66-9E6B-BB2005850479.qvnote
    │   ├── content.json
    │   ├── meta.json
    │   └── resources
    │       ├── 12EDC7A8-A468-49BD-A742-3856B829129B.png
    │       ├── 1A766DDD-68AE-4AC3-BC2D-2CE310B2A8F5.png
    │       ├── 57BF000A-0766-4C48-B4DF-0AB962C0D8BA.png
    │       ├── 686554D4-4EAD-4AAA-9248-DA72C60CD808.png
    │       ├── 6E03AF8F-DE1E-4BE6-8B5E-730B4A1B72E2.png
    │       └── C3FF7A1B-7664-445F-A72A-102882B5C453.png
    ├── EDFC03DD-4E78-4405-A560-4A902FCE4312.qvnote
    │   ├── content.json
    │   └── meta.json
    ├── FABE685F-D170-4B8F-AB4F-5CD50B91C50C.qvnote
    │   ├── content.json
    │   ├── meta.json
    │   └── resources
    │       └── 1FC1261E-1109-47E7-A62D-4268E55AD526.png
    └── meta.json
```

content.json存放文章，比如新建一个这样的3个cell的文章：

![](/img/software/quiver-demo.png)

其对应的content.json为：

```
{
  "title": "Hello",
  "cells": [
    {
      "type": "text",
      "data": "text"
    },
    {
      "type": "code",
      "language": "javascript",
      "data": "code"
    },
    {
      "type": "markdown",
      "data": "markdown"
    }
  ]
}
```

meta.json存放文章元数据：

```
{
  "created_at" : 1470190687,
  "tags" : [

  ],
  "title" : "Hello",
  "updated_at" : 1470190745,
  "uuid" : "49571CBF-FBB3-411E-9C92-44959246DB89"
}
```
