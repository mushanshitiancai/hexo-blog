---
title: FFmpeg笔记-基本使用
date: 2018-01-10 09:40:45
categories:
tags: [ffmpeg]
---

FFmpeg是目前最牛逼的开源跨平台音视频处理工具。

<!--more-->

## 准备知识

我不是音视频编解码出身的，对于这一块非常的不了解，导致在学习FFmpeg的时候云里雾里的，所以学习之前最好看些资料对音视频编解码有点认识。

- [[总结]FFMPEG视音频编解码零基础学习方法 - CSDN博客](http://blog.csdn.net/leixiaohua1020/article/details/15811977)
- [[总结]视音频编解码技术零基础学习方法 - CSDN博客](http://blog.csdn.net/leixiaohua1020/article/details/18893769)
- [视频格式那么多，MP4/RMVB/MKV/AVI 等，这些视频格式与编码压缩标准 mpeg4，H.264.H.265 等有什么关系？ - 知乎](https://www.zhihu.com/question/20997688)
- [各种音视频编解码学习详解 - CSDN博客](http://blog.csdn.net/flyingqr/article/details/12705289)

## 安装

Windows和MacOS用户可以从[Builds - Zeranoe FFmpeg](https://ffmpeg.zeranoe.com/builds/)下载编译好的FFmpeg，解压加入环境变量PATH即可使用。

同时安装包我上传到百度云中，还有一些测试用的视频：
链接: https://pan.baidu.com/s/1nwLh4hF 密码: v7yt

## 播放视频，FFplay

学习FFmpeg免不了要看效果，而windows的自带播放器又垃圾得一匹，而且我们会需要看视频的元数据，看他的编码，用一般的这播放器，能看但是不是很方便。其实FFmpeg自带了一个播放器FFplay！

FFplay是结合FFmpeg和SDL实现的一个简易的跨平台播放器。使用起来特别简单：

```
ffplay [选项] ['输入文件']
```

而且控制台会打印出视频的各种信息，对于我们查看视频转换结果非常有帮助。

![](/img/ffmpeg/ffplay.png)

FFplay具体文档：
- [ffplay Documentation](http://ffmpeg.org/ffplay.html)
- [FFplay使用指南](http://blog.csdn.net/wishfly/article/details/44222297)
- [ffplay的快捷键以及选项](http://blog.csdn.net/leixiaohua1020/article/details/15186441)

## 获取视频信息，FFprobe

FFplay命令中会打印出视频的元数据，那如果我们只是想获取这些数据而不想播放视频呢？比如在程序中我们想获取视频的时长，要用什么命令？用FFprobe命令。

```
ffprobe [选项] ['输入文件']
```

看输出一定觉得很熟悉，因为和FFplay打印出的信息一模一样：

![](/img/ffmpeg/ffprobe.png)

我们还可以使用一些参数：
- `-v quiet`：不打印日志，这样默认的输出就不会显示了，就不会干扰我们想要输出的信息
- `-print_format json`：用JSON格式打印出信息。还支持xml，csv，flat，ini格式
- `-show_format`：打印出输入的格式信息
- `-show_streams`：打印出每个流的信息

默认的输出是比较简略的，我们可以使用`-show_format`和`-show_streams`打印出我们想要的详细信息，比如：

```
ffprobe -v quiet -show_format -print_format json res\BCSPA039_pre.mp4
```

![](/img/ffmpeg/ffprob-json.png)

然后我们程序读取解析json，获取duration字段就是视频的时长。

## 视频操作，FFmpeg

ffmpeg命令的语法：

```
ffmpeg [global_options] {[input_file_options] -i input_url} ... {[output_file_options] output_url} ...
```

ffmepg支持多个输入源（文件，管道，网络流，采集设备），通过`-i`指定输入。ffmpeg支持多个输出，命令行中所有无法被解析为参数的字段都会被作为输出的url。

参数一般作用于且只作用于下一个指定的文件，所以参数的位置是非常重要的。所以全局生效的参数要在最前面。

ffmpeg命令完整的说明参考：
- [ffmpeg Documentation](http://ffmpeg.org/ffmpeg.html)
- [ffmpeg参数中文详细解释](http://blog.csdn.net/leixiaohua1020/article/details/12751349)

ffmpeg的参数太多了，我们还是通过常用命令来学习会比较好。

### ffmpeg例子

#### 分离音视频

```
ffmpeg -i input_file -vcodec copy -an output_file_video　　//只输出视频
ffmpeg -i input_file -acodec copy -vn output_file_audio　　//分输出音频
```

参数解释：
- `-i`：指定输入文件
- `-vcodec`：指定视频编码器，这里指定copy是一个特殊值，表示复制输入的视频流到输出不做更改
- `-an`：关闭音频输出
- `-vn`：关闭视频输出

#### 视频转码

```
ffmpeg -i input_file output_file
```

这是最简单的视频转码命令，ffmpeg会从input的内容推测格式，从output_file的后缀名推测格式，然后进行转码输出。

来看一个我在工作中接触的比较复杂的视频转码命令：

```
ffmpeg -i "#src#" -y -s 1920x1080 -vcodec libx264 -c:a libvo_aacenc -b:a 48k -ar 44100 -ac 2 -qscale 4 -f #targetFmt# -movflags faststart -map 0:v:0 -map 0:a? "#destDir#/1080p/#fileNameNoEx#.mp4"
```

参数解释：
- `-y`：覆盖输出文件
- `-s 1920x1080`：设置帧的大小，也就是视频分辨率，格式为`WxH`
- `-vcodec libx264`：设置视频编码器，`-codec:v libx264`是另外一种写法
- `-c:a libvo_aacenc`：设置音频编码器
- `-b:a 48k`：设置音频的比特率
- `-ar 44100`：设置音频采样率为44100
- `-ac 2`：设置声道数
- `-f #targetFmt#`：设定输出的格式。如果不指定，则会输入文件从内容中推测，输出文件通过后缀名推测。
- `-movflags faststart`：把MOV/MP4文件的索引信息放到文件前面以支持边下边播
- `-map 0:v:0`：选择输入文件的第一个视频流输出
- `-map 0:a?`：选择输入文件的音频流输出，如果没有不报错

#### 视频截图

指定时间截取一帧作为输出：

```
ffmpeg -i input.flv -ss 00:00:14.435 -vframes 1 out.png
```

参数解释：
- `-ss`：如果作用于输入文件表示seek输入文件到这个位置，但是很多格式不支持seek的，所以只能做个大概。如果作用于输出文件，则输入会被解码，但是指定时间之前的数据都会被忽略。这里是作用于输出文件，所以相当于00:00:14.435之前的内容都被忽略了
- `-vframes 1`：指定输出多少帧，这里就输出一帧。`-vframe`是`-frames:v`的别名。

每隔一段时间截一张图：

```
# 每一秒输出一帧图像为图片, 图片命名为 out1.png, out2.png, out3.png,依次顺序输出：
ffmpeg -i input.flv -vf fps=1 out%d.png

# 每一分钟截一次图, 命名 img001.jpg, img002.jpg, img003.jpg, 依次顺序递增：
ffmpeg -i myvideo.avi -vf fps=1/60 img%03d.jpg

# 每十分钟输出一张图片:
ffmpeg -i test.flv -vf fps=1/600 thumb%04d.bmp
```

参数解释：
- `-vf fps=1`：设置视频的filter为fps。后面参数表示一秒几帧。这里设置为1，表示一秒一帧。`-vf`是`-filter:v`的别名
- `out%d.png`：输出多个图片，`%d`占位符表示数字，从1开始。还可以使用`%2d`指定固定两位

fps过滤器的文档：[fps Documentation](http://ffmpeg.org/ffmpeg-all.html#fps-1)

## 多说一句

在学习ffmpeg的过程中，阅读了几篇非常好的博客，然后发现作者都是雷霄骅。没想到他竟然在2016年的时候去世了。唉，又是一个业内悲剧，而且他竟然是在大学里猝死的，真的是太拼了。努力虽好，也得注意身体啊。

这里引用[如何看待雷霄骅之死？](https://www.zhihu.com/question/49211380)里的一句话

> 天妒英才，不夸张的说，如果不知道雷霄骅，可能你音视频还没入门

的确，他的文章对我入门使用ffmpeg起了很大的帮助。谢谢雷神，一路走好。

## 参考资料
- [FFmpeg](http://ffmpeg.org/)
- [ffplay Documentation](http://ffmpeg.org/ffplay.html)
- [FFplay使用指南](http://blog.csdn.net/wishfly/article/details/44222297)
- [FFprobe使用指南](http://blog.csdn.net/stone_wzf/article/details/45378759)
- [[总结]FFMPEG视音频编解码零基础学习方法 - CSDN博客](http://blog.csdn.net/leixiaohua1020/article/details/15811977)
- [[总结]视音频编解码技术零基础学习方法 - CSDN博客](http://blog.csdn.net/leixiaohua1020/article/details/18893769)
- [【FFmpeg】FFmpeg常用基本命令 - 一点心青 - 博客园](https://www.cnblogs.com/dwdxdy/p/3240167.html)
- [mp4格式文件转码后处理（qt-faststart工具介绍） - 杂食菜熊的Blog](http://xdsnet.github.io/index.html?name=%E6%9D%82%E8%B0%88:mp4%E6%A0%BC%E5%BC%8F%E6%96%87%E4%BB%B6%E8%BD%AC%E7%A0%81%E5%90%8E%E5%A4%84%E7%90%86)
- [ffmpeg 官方文档 上篇 （译） - 直播技术知识库](http://lib.csdn.net/article/liveplay/45723)
- [Chinese_Font_从视频中每X秒创建一个缩略图 – FFmpeg](https://trac.ffmpeg.org/wiki/Chinese_Font_%E4%BB%8E%E8%A7%86%E9%A2%91%E4%B8%AD%E6%AF%8FX%E7%A7%92%E5%88%9B%E5%BB%BA%E4%B8%80%E4%B8%AA%E7%BC%A9%E7%95%A5%E5%9B%BE)