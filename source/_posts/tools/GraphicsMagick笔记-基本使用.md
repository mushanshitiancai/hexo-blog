---
title: GraphicsMagick笔记-基本使用
date: 2018-01-09 19:32:46
categories:
tags: [gm,graphicsmagick]
---

GraphicsMagick是非常强大的图片处理工具。支持超过88中图片格式，包含 DPX, GIF, JPEG, JPEG-2000, PNG, PDF, PNM, TIFF这些常用的格式。图片分享网站Flickr和电商Etsy这两家公司用的就是

<!--more-->

## 安装

windows可以从这个FTP下载可执行安装程序：ftp://ftp.graphicsmagick.org/pub/GraphicsMagick/windows/

## 常用命令

GraphicsMagick包含了许多子命令，常用命令有：
- convert：转换图片格式和大小，同时叠加变换操作（裁减，模糊等）
- composite：合并多张图片为一张图片

## convert命令
把一种格式的一张图片转换为另外一种格式的图片，在转换同时可以应用图片操作。

语法：

```
gm convert [ options ... ] input_file [ options ... ] output_file 
```

### convert命令例子

**缩略图：**

```
gm convert -size 120x120 cockatoo.jpg -resize 120x120 +profile "*" thumbnail.jpg
```

参数说明：
1. `-size 120x120`并不是指定原图格式，而是提示JPEG decoder只需要120x120的处理即可，这样在图片解码给缩略图操作的时候就可能不用完整的信息，从而加速命令的执行。
2. ` -resize 120x120`指定输出的图片的尺寸，这里不会强制缩放图片到120x120，而是把长边缩小为120。
3. `+profile "*"'`指定移除ICM, EXIF, IPTC或者其他图片扩展信息，这样可以减小生成的缩略图的大小

问题：size和resize只能指定NxN？如果是NxM是什么效果？

**文字水印：**

```
gm convert -gravity southeast -font ArialBold -pointsize 45 -fill red  -draw "text 10,10 hello" input.jpg output.png
```

参数说明：
1. `-gravity southeast` 指定右下角水印
2. `-font ArialBold` 指定字体
3. `-pointsize 45` 指定文字大小
4. `-fill red` 指定文字颜色
5. `-draw "text 10,10 hello"` 指定文字颜色和位置

### convert命令其他常用参数

- `-quality <value>`
  设置JPEG/MIFF/PNG/TIFF格式图片的压缩级别

## composite命令

语法：

```
gm composite [ options ... ] change-image base-image [ mask-image ] output-image 
```

## composite命令例子

**图片叠加（把a叠加到base上）：**

```
gm composite a.png base.png output.png
```

**图片水印：**

```
gm composite -gravity southeast -geometry +50+50 -dissolve 50 watermark.jpg input.jpg output.png
```

参数说明：
gravity：设置坐标轴原点到左下角
geometry：偏移50,50

## 参考资料
- 官网文档：http://www.graphicsmagick.org/GraphicsMagick.html
- [ImageMagick简介、GraphicsMagick、命令行使用示例 - 赵磊的技术博客 - ITeye博客](http://elf8848.iteye.com/blog/382528)
- [GraphicsMagick为图片添加水印 - archoncap - 博客园](https://www.cnblogs.com/archoncap/p/4578433.html)
- [ImageMagicK之gravity参数详解 | 网络进行时](http://www.netingcn.com/imagemagick-gravity.html)