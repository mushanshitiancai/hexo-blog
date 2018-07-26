---
title: GraphicsMagick笔记-基本使用
date: 2018-01-09 19:32:46
categories:
tags: [gm,graphicsmagick]
toc: true
---

GraphicsMagick是非常强大的图片处理工具。支持超过88中图片格式，包含 DPX, GIF, JPEG, JPEG-2000, PNG, PDF, PNM, TIFF这些常用的格式。图片分享网站Flickr和电商Etsy这两家公司用的就是GraphicsMagick。

<!--more-->

## 安装

windows可以从这个FTP下载可执行安装程序：ftp://ftp.graphicsmagick.org/pub/GraphicsMagick/windows/

同时安装包我上传到百度云中，还有一些测试用的图片：
链接: https://pan.baidu.com/s/1nwLh4hF 密码: v7yt

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
2. `-resize 120x120`指定输出的图片的尺寸，这里不会强制缩放图片到120x120，而是把长边缩小为120。
3. `+profile "*"'`指定移除ICM, EXIF, IPTC或者其他图片扩展信息，这样可以减小生成的缩略图的大小


### `-resize`参数

```
-resize <width>x<height>{%}{@}{^}{!}{<}{>}
```

默认情况下，`width`和`height`指的是最大值，并且会保持原图的长宽比。也就是说图片缩放会，会最大化的占用`width*height`这个区域。可以想象为，使用`width*height`画了一个矩形，gm会缩放图片，使图片面积最大，但是又能放入这个矩形中。也就是图片的至少有一个边，与这个矩形对应的边长度相等。

如果在尺寸后面追加`^`，表示`width`和`height`指的是最小值，并且会保持原图的长宽比。可以想象为，使用`width*height`画了一个矩形，gm会缩放图片，使图片面积最小，但是又能占满这个矩形。

如果在尺寸后面追加`!`，表示不保留原图的长宽比，强制缩放为`width`和`height`指定的值。

如果只指定了`width`并且没有跟随`x`，则`height`的值会设置为与`width`一样。`-resize 10`与`-resize 10x10`是一样的。

如果指定为`<width>x`或者`x<height>`，则宽/高使用对应的值，另外一条边根据原图长宽比计算出。

如果在尺寸后面追加`%`，则使用比例的方式计算尺寸。

如果在尺寸后面追加`@`，表示尺寸指的是最大的面积大小，gm保证缩放后的图片的`width*height`小于等于这个面积。

有一种很常见的需求，比如要求图片缩放为`640x480`如果图片本身小于这个尺寸了，就不动，只把大于这个尺寸的图片缩放。`>`和`<`这两个后缀就是用于处理这种需求的。

如果在尺寸后面追加`>`，表示图片的长度或者宽度大于指定的尺寸才进行处理。

如果在尺寸后面追加`<`，表示图片的长度或者宽度小于指定的尺寸才进行处理。

上面说的需求可以使用`640x480>`来实现。这样如果图片尺寸是`256x256`就不会处理，如果是`512x512`或者`1024x1024`就会被缩放为`480x480`。

`-resize`的参数应该使用双引号括起来，以免被shell解读。

在`convert`命令中，`-resize`参数作用与`-geometry`作用一样。

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

### composite命令例子

**图片叠加（把a叠加到base上）：**

```
gm composite a.png base.png output.png
```

**图片水印：**

```
gm composite -gravity southeast -geometry +50+50 -dissolve 50 watermark.jpg input.jpg output.png
```

参数说明：
`-gravity southeast`：设置坐标轴原点到左下角
`-geometry +50+50`：偏移50,50
`-dissolve 50`：不透明度50

### `-gravity`参数

```
-gravity <type>
```

`gravity`参数用于指定`change-image`叠加在`base-image`的什么位置。

有9个位置可以选择，可以联想骰子上的9点：`NorthWest`, `North`, `NorthEast`, `West`, `Center`, `East`, `SouthWest`, `South`, `SouthEast`.

默认的位置是`NorthWest`，也就是左上角。

### `-geometry`参数

```
-geometry {+-}<x>{+-}<y>
```

`-geometry`是一个很强大的参数，在不同的命令中有不同的效果。在`convert`命令中，他用于缩放图片。而在`composite`命令中，他用于指定`change-image`的偏移。

`+x+y`表示横向正向偏移`x`，纵向正向偏移`y`。偏移的方向与`gravity`参数有关。

如果`gravity`参数的取值为`NorthEast`, `East`, `SouthEast`，则`x`表示`change-image`右边与`base-image`右边的距离。其他情况表示`x`表示`change-image`左边与`base-image`左边的距离。

如果`gravity`参数的取值为`SouthWest`, `South`, `SouthEast`，则`y`表示`change-image`下边与`base-image`下边的距离。其他情况表示`x`表示`change-image`上边与`base-image`上边的距离。

偏移量不受`%`号影响。只支持像素单位。

## 参考资料
- 官网文档：http://www.graphicsmagick.org/GraphicsMagick.html
- [ImageMagick简介、GraphicsMagick、命令行使用示例 - 赵磊的技术博客 - ITeye博客](http://elf8848.iteye.com/blog/382528)
- [GraphicsMagick为图片添加水印 - archoncap - 博客园](https://www.cnblogs.com/archoncap/p/4578433.html)
- [ImageMagicK之gravity参数详解 | 网络进行时](http://www.netingcn.com/imagemagick-gravity.html)
