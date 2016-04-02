---
title: atom-note项目日志
date: 2015-10-01 15:25:28
tags: [project]
---

目前此项目暂停。转向fir项目。

## 背景
一路过来用了很多笔记软件，尝试过为知笔记，印象笔记，有道云笔记，Zim，了解过vim-wiki，org-mode，TiddlyWiki，gollum，mdwiki等。

实际的使用上，从高中开始使用为知笔记，一直到大学毕业后，无意中了解到Zim，使用Zim+快盘一段时间，Zim虽然看起来简陋，实际上还是很强大的，也可以使用git等版本控制工具作为后台。

这么多笔记软件，用着总是感觉不顺手，比如比较诟病的一点，就是笔记软件的编辑功能，像为知笔记，有道云笔记，印象笔记，这三个应该算是现在最流行的云笔记了。从普通用户的视角上来看，编辑功能也是够用了，富文本编辑器，可以插入图片等附近。但是作为程序员，这样就远远不够了，想用markdown？印象笔记和有道云笔记就跪了，为知笔记虽然支持，但是很不完美。印象笔记虽然有类似马克飞象这种第三方编辑器入口，提供了很好的markdown编辑体验，但是不是原生支持，就是感觉不爽。

Zim底子里是wiki。保存的文件也都是纯文本。他的半所见即所得的编辑器虽然简单但也够用了。日记功能，TODO功能都很实用，也有一些强大插件。比较符合心目中的"程序员的PKM"。

一直就想写一个至少自己用着爽的笔记软件，也的确，每个人有不同的喜欢，如果真的要做到最符合自己心意，也只能自己写一个了。加上换了mac后，Zim没有mac版，所以着手开发这个atom-note。

为什么选择atom插件这种形式呢。上面也说了，编辑的舒适程度，我是比较看重的，自己写一个编辑器，工作量太大，所以想依附于现有编辑器，改写代码或者是以插件形式。Emacs和vim我学不会，所以合适的候选编辑器就剩下sublime和atom了。其实从编辑器本身来看，sublime现在还是比atom好用的。但是了解过后，不得不说，atom就是未来编辑器该有的模样了。设计很先进，一整套的HTML5+nodejs技术。扩展性很强，因为就是一个浏览器啊。

所以，atom-note。

## 规划
### v0.0.1（2015年10月1日~）
完成这个版本后，atom-note大体上可以使用，我将会把插件放到atom插件仓库中
- [ ] 设计笔记的存储格式（不再采用zim模式）
- [ ] 新建笔记本
- [ ] 新建笔记
- [ ] 插入笔记链接
- [x] 插入剪贴板图片（可以使用快捷键插入剪贴板中的图片，图片会被放到当前笔记对应的附件目录中）
- [ ] 快捷键开关TODO
- [ ] 快捷键打开今日日记
- [ ] 笔记本树视图（atom-note-tree-view，显示笔记的树形结构，而不是文件夹的树形结构）

### v0.0.2
- [ ] 删除图片（图片被删除时，询问是否保留附件目录中的图片文件）

### TODO
- zend书写模式？
- 日历[<0;40;10M]界面
- 快速唤出收集箱
- 标题折叠
- 锚点
- atom-note需要对markdown做哪些扩展？
- 如何集成ascii-doc？
- 代码折叠(贴长代码如果不能折叠,还是很痛苦的)
- focus模式
- markdown+outliner，这样才能让markdown更有生命力
- 学习FoldingText，Ulysses III
- 学习 Introduction | FoldingText for Atom User's Guide https://jessegrosjean.gitbooks.io/foldingtext-for-atom-user-s-guide/content/
- 学习atom-typescript中如何显示鼠标悬浮提示
- 图片是保存在本地的，这对于网络分享不便。加一个功能，转换成网络格式，也就是把图片都上传到某图床后替换连接的格式。
- atom默认的markdown高亮，所有级别的标题都是一个高亮，可以分级设置为不同的颜色

## 概念与设计
## 名词

- 笔记本/笔记本文件夹：一个笔记本是一个包含有笔记信息的目录
- 笔记：笔记是一个markdown文件
- 分类/分类文件夹：分类是笔记本目录中的一个文件夹，分类中可以有可以存放笔记或者子分类
- 笔记本描述文件：笔记本根目录下，固定存在一个note.json文件。与nodejs的package.json类型，用来记录笔记本的元信息
- 附件目录：笔记本根目录中，固定存在一个attachment目录，用来存放该笔记本的所有附件。

### 目录结构

```
atom-note-demo
├── note.json
├── categoy1
│   └── note1.md
├── categoy2
│   ├── note2.md
│   └── sub_category
│       └── note3.md
└── attachment
    └── categoy1
        └── note1
            ├── attachment1.xxx
            └── image_name.png
```

说明：
- 文件夹起到分类的效果
- 分类可以有子分类
- 附件统一放到attachment目录中，按照笔记对应的路径来存放

### note.json结构

```
{
  "name": "first-note-book",
  "author": "tobyn",



  "format": "atom-note-v0.01"
}
```

## 日志
### ~2015年10月07日
国庆这几天，效率低得不行。大致了解了atom插件的编写，还有spec测试用例的写法，atom这个测试集成设计的也很好。测试过的代码就是放心。

NotebookCommand
- [x] open-today-journal

NotebookUtil
- [x] isLegalNotebook
- [x] getActiveNotebookPath
- [x] getJournalPath
- [x] openJournal

### 2015年10月10日~
- [x] NoteUtil::initNote
- [x] NoteUtil::generateNoteHeader

初始化文件头，需要使用YAML [The Official YAML Web Site](http://yaml.org/)

```
npm install js-yaml
```

- [x] NoteUtil::getActiveNoteFolder
- [x] NoteUtil::ensureActiveNoteFolder
- [x] NoteUtil::insert-image
- [x] Util::getPrefixText
- [x] NotebookCommand::insert-image
- [x] 配置insert-image命令到ctrl+v上（TODO 这个在win上就有问题了）
- [x] 如果配置到系统默认的粘贴快捷键上，在剪贴板中没有图片时，需要返回默认粘贴行为，如何做到？
- [x] atom如何为不同的系统设置不同快捷键？
- [x] 如果用户在粘贴图片时没有选中文本作为图片的标题，则使用光标所在行的文本作为标题（关键在于判断是否是合法文件名）
- [x] 学习snippets.coffee
- [ ] 分离检查是否进入插入图片代码与插入图片代码
- [ ] 对于选中作为图片标题的文本，检查其合法性
- [x] 在readme中添加图片两种插入方式的feature

### 2015年10月16日
想了想，如果要使用zim的文件系统，那么就得定制tree-view。这还是很麻烦的。为何不直接用文件系统格式呢？

似乎也可行，而且在使用其他编辑器或者是文件管理器中打开时，会更加方便。

那就这么做吧。只要简单扩展tree-view即可。

如果非要在目录节点上也记录信息，可以使用index.md。

### 2015年10月19日
- [x] 更新开发日志-名词，目录设计
- [ ] 更新获取附件目录函数NoteUtil::getActiveNoteFolder/NoteUtil::ensureActiveNoteFolder

### 2015年10月20日
写着coffee还是不爽,稍微要改点儿带重构性质的,就无从下手.决定了,试试typescript.

- [x] 入门typescript,看官方文档
- [x] 学习如何搭建typescript+gulp工作流

步骤如下:

安装gulp相关依赖
npm install --save-dev gulp gulp-typescript gulp-sourcemapsdel gulp-tslint

安装tsd与类型定义文件
npm install tsd -g
tsd init
tsd install atom --save

编写tsconfig.json
编写gulpfile.js

### 2015年10月28日
DefinitelyTyped中的atom类型定义中没有CompositeDisposable这个类型

atom: CompositeDisposable not declared · Issue #4482 · borisyankov/DefinitelyTyped
https://github.com/borisyankov/DefinitelyTyped/issues/4482

看来需要自己添加？

- [x] 能不侵入现有的定义来定义么？--能
- [] 能不侵入现有的定义来定义么？《--同名的会覆盖还是报错？

类型定义中没有atom.project.getPaths，搜索了一下，别的atom-typescript中竟然没用到。。。这是怎么回事。而且atom-typescript中也没用到CompositeDisposable，真是日了狗了。

### 2015年11月09日
- [ ] 如何获取用户输入？

### 2015年11月12日
atom插件的界面，参考style guide就行了。

典型的输入框代码：

```html
<div class='block'>
    <label>You might want to type something here.</label>
    <atom-text-editor mini>Something you typed...</atom-text-editor>
</div>
<div class='block'>
    <label class='icon icon-file-directory'>Another field with an icon</label>
    <atom-text-editor mini>Something else you typed...</atom-text-editor>
</div>
<div class='block'>
    <button class='btn'>Do it</button>
</div>
```

### 2015年12月19日
很久没动，主要原因，是闲麻烦。。。typescript转javascript这个过程，涉及的东西还是比较多。决定回到master分支上继续开发。

而开发环境是。。。Sublime。不得不说，对已编辑器来说，atom还有许多地方没有做好，在我的mac上，启动竟然需要5秒。。。Sublime是瞬间。。。

### 2016年01月09日
到2016年了呢。

今天写了两篇关于space-pen的博客：

- [Atom的view系统SpacePen - - 博客频道 - CSDN.NET](http://blog.csdn.net/mazhibinit/article/details/50357805)
- [Atom的view系统2-SpacePenViews - - 博客频道 - CSDN.NET](http://blog.csdn.net/mazhibinit/article/details/50488931)

打算弄一个根据参数配置的输入对话框类。

> 发现：文件名使用my-note.coffee格式，对应类MyNote。Atom项目的风格是这样的。

### 2016年01月16日
- [x] 完成create-notebook命令
- [ ] 更新InputView，支持多个输入域
- [x] 完成add-note命令初版
- [x] 完成Notebook的一些方法：getAllNotebookPathInProject，getActiveNotebook，isLegalNotebookPath
- [x] 完成NotebookConfig的一些方法：isLegalNotebookConfig，readFromFile，writeToFile
- [x] 添加Note相关类

### 2016年01月17日
- [ ] 提示使用atom.notifications

学吉他的路上突然想到。如果我把Notebook类暴露到全局，那么就可以供其他插件使用，其他人就可以为atom-note开发插件！想想就好激动。

还有一点，就是需要在tree-view的菜单上加入atom-note的功能，如何做到呢？

👆有眉目了。

    $('.tree-view-resizer.tool-panel').spacePenView.selectedEntry().getPath()

这就可以获取当前选中的项目的路径。

在menu/atom-note.cson中添加

```
'context-menu':
  'atom-text-editor': [
    {
      'label': 'Toggle atom-note'
      'command': 'atom-note:toggle'
    }
  ]
  '.tree-view.full-menu': [
    {'type': 'separator'}
    {'label': 'test', 'command': 'tree-view:add-file'}
    {'type': 'separator'}
  ]
```

就可以在treeview中添加菜单了。Atom的设计的确很出色。

### 2016年01月23日
又突然想到写一个通用的笔记后端，可以像语言后端一样，供许多编辑器使用。。。

太折腾了我。。。这等于又重新开始了。。。

## 问题
- 使用electron的剪贴板模块，保存截图到文件中，分辨率会比较低，这是为什么？

### atom如何为不同的系统设置不同快捷键？
atom编辑器在body标签上，标明了是那种平台：

```html
<body tabindex="-1" class="platform-darwin is-blurred">
  ...
</body>
```

所以可以这么绑定：

```
".platform-win32 atom-text-editor[data-grammar~='gfm']":
  ...
```

### 如果覆盖了默认快捷键，如果在插件代码解释后，会继续执行其他绑定，如何中断？
使用`e.abortKeyBinding()`

```
editor.command 'snippets:expand', (e) =>
  if @cursorFollowsValidPrefix()
    @expandSnippet()
  else
    e.abortKeyBinding()
```


## 关键词
- Git Large File Storage v1.0

## temp

```
"activationCommands": {
  "atom-text-editor": [
    "atom-note:insert-list-new-line",
    "atom-note:test",
    "atom-note:insert-image"
  ]
},
```
