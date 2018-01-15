---
title: jQuery笔记-编写插件
date: 2016-04-02 11:49:39
categories: [JavaScript]
tags: [javascript,js,jquery]
---

翻译了jQuery插件开发的两篇文章：

- [How to Create a Basic Plugin | jQuery Learning Center](https://learn.jquery.com/plugins/basic-plugin-creation/)
- [Advanced Plugin Concepts | jQuery Learning Center](https://learn.jquery.com/plugins/advanced-plugin-concepts/)

<!-- more -->

假设你的代码中有如下代码：

    $( "a" ).css( "color", "red" );

如果`css( "color", "red" )`在你的项目中是非常非常常见的一个操作，你可以把它包装成一个插件，方便调用。

如果你了解javascript的面向对象的编写方式（不了解就去翻翻红宝书吧）。可以猜到`css`方法是定义在jQuery（也就是`$`）的原型上的。事实也是如此。为了熟悉方便吧，jQuery让`$.fn = $.prototype`。所以如果是要扩展jQuery方法，在`$.fn`上添加方法就行了：

```
$.fn.greenify = function() {
    this.css( "color", "green" );
};
 
$( "a" ).greenify();
```

因为`greenify()`是定义在`$.prototype`中的，所以直接使用this就行了，不用再`$(this)`了。

但是这个写法并不好。不好的地方有两处：

1. 不能在`greenify()`上进行jQuery风格的`链式调用`
2. 直接使用`$`

### 链式调用
第一个问题，让`greenify()`返回jQuery对象就可以进行链式调用了：

```
$.fn.greenify = function() {
    this.css( "color", "green" );
    return this;
};
```

### 兼容`$`
第二个问题，虽然我们平时都使用`$`进行编程，但是`$`在js世界中被不止一个库使用。所以如果你把插件硬编码到`$`上，那么如果使用者调用了`jQuery.noConflict()`你的插件就废了。所以我们要做一些特殊处理：

```
(function ( $ ) {
 
    $.fn.greenify = function() {
        this.css( "color", "green" );
        return this;
    };
 
}( jQuery ));
```

### 尽量少的侵入jQuery
因为jQuery有很多插件，所以要经理避免和其他插件产生冲突。一个最佳实践就是少的侵入jQuery，也就是尽量少的在`$.fn`上添加函数。尽量做到一个插件只在`$.fn`上添加一个函数。

比如：

```
(function( $ ) {
 
    $.fn.openPopup = function() {
        // Open popup code.
    };
 
    $.fn.closePopup = function() {
        // Close popup code.
    };
 
}( jQuery ));
```

在`$.fn`上添加了两个函数，不太好，可以这么改写：

```
(function( $ ) {
 
    $.fn.popup = function( action ) {
 
        if ( action === "open") {
            // Open popup code.
        }
 
        if ( action === "close" ) {
            // Close popup code.
        }
 
    };
 
}( jQuery ));
```

### 处理多个元素
很多时候jQuery对象指向的是一组DOM，所以如果你的插件需要能够处理一个或多个元素的jQuery对象时，需要使用`each()`函数来处理每个元素：

```
$.fn.myNewPlugin = function() {
 
    return this.each(function() {
        // Do something to each element here.
    });
 
};
```

注意`each()`函数返回jQuery对象，所以直接放回`each()`的结果就可以支持链式调用了。

### 获取参数
复杂的插件是需要很多参数来配置的。通用的做法是在插件的入口函数中添加一个`options`参数，作为传递配置的对象。插件内部维护一个填上了默认参数的对象，让后用户传入的参数与默认参数合并：

```
(function ( $ ) {
 
    $.fn.greenify = function( options ) {
 
        // This is the easiest way to have default options.
        var settings = $.extend({
            // These are the defaults.
            color: "#556b2f",
            backgroundColor: "white"
        }, options );
 
        // Greenify the collection based on the settings variable.
        return this.css({
            color: settings.color,
            backgroundColor: settings.backgroundColor
        });
 
    };
 
}( jQuery ));
```

对于默认参数，更标准的做法是建立一个`$.fn.xxx.defaults`变量，用来存放默认参数：

```
// Plugin definition.
$.fn.hilight = function( options ) {
 
    // Extend our default options with those provided.
    // Note that the first argument to extend is an empty
    // object – this is to keep from overriding our "defaults" object.
    var opts = $.extend( {}, $.fn.hilight.defaults, options );
 
    // Our plugin implementation code goes here.
 
};
 
// Plugin defaults – added as a property on our plugin function.
$.fn.hilight.defaults = {
    foreground: "red",
    background: "yellow"
};
```

这样做有什么好处呢？

我觉得好处有二：

1. 用户知道哪里存放了默认配置
2. 用户可以很方便的修改默认参数

第二点用户是这么做的：

    $.fn.hilight.defaults.foreground = "blue";

这样用户就不用每次都传入`foreground`这个配置了。做到了简单修改默认参数。

## jQuery插件进阶知识
### 默认参数
这个上文提到了。

### 让用户可以定制插件的执行过程
这个其实是一种设计模式吧。暴露一些可以供用户定制的接口，提高你的插件的可定制性。

说不清，看代码吧：

```
// Plugin definition.
$.fn.hilight = function( options ) {
 
    // Iterate and reformat each matched element.
    return this.each(function() {
 
        var elem = $( this );
 
        // ...
 
        var markup = elem.html();
 
        // Call our format function.
        markup = $.fn.hilight.format( markup );
 
        elem.html( markup );
 
    });
 
};
 
// Define our format function.
$.fn.hilight.format = function( txt ) {
    return "<strong>" + txt + "</strong>";
};
```

用户可以通过修改`$.fn.hilight.format`来定制展现方式。

### 保持插件私有方式不被用户访问
这也是一个设计模式。对应到Java中就是不想被外部访问的方法，用`private`来修饰。Java中可以通过闭包来实现方法私有：

```
// Create closure.
(function( $ ) {
 
    // Plugin definition.
    $.fn.hilight = function( options ) {
        debug( this );
        // ...
    };
 
    // Private function for debugging.
    function debug( obj ) {
        if ( window.console && window.console.log ) {
            window.console.log( "hilight selection count: " + obj.length );
        }
    };
 
    // ...
 
// End of closure.
 
})( jQuery );
```

### 提供适当的配置项
一个插件，并不是配置项越多越好的。比如下面这个反模式：

```
jQuery.fn.superGallery = function( options ) {
 
    // Bob's default settings:
    var defaults = {
        textColor: "#000",
        backgroundColor: "#fff",
        fontSize: "1em",
        delay: "quite long",
        getTextFromTitle: true,
        getTextFromRel: false,
        getTextFromAlt: false,
        animateWidth: true,
        animateOpacity: true,
        animateHeight: true,
        animationDuration: 500,
        clickImgToGoToNext: true,
        clickImgToGoToLast: false,
        nextButtonText: "next",
        previousButtonText: "previous",
        nextButtonTextColor: "red",
        previousButtonTextColor: "red"
    };
 
    var settings = $.extend( {}, defaults, options );
 
    return this.each(function() {
        // Plugin code would go here...
    });
 
};
```

太多太细节的配置项只会让用户是去耐心。所以琢磨用户的需求吧，提供那些关键的配置项。

### 不要为你的插件创造特殊的语法

```
var delayDuration = 0;
 
switch ( settings.delay ) {
 
    case "very short":
        delayDuration = 100;
        break;
 
    case "quite short":
        delayDuration = 200;
        break;
 
    case "quite long":
        delayDuration = 300;
        break;
 
    case "very long":
        delayDuration = 400;
        break;
 
    default:
        delayDuration = 200;
 
}
```

这个插件定义了许多特定的值对应的字符串。用户需要额外学习才能掌握这些常量。经历避免这种设计。

### 让用户可以得到元素的所有控制权
如果你的插件涉及到创造DOM，应该让用户可以控制DOM的创建。一个不好的例子：

```
// Plugin code
$( "<div class='gallery-wrapper' />" ).appendTo( "body" );
 
$( ".gallery-wrapper" ).append( "..." );
```

上面这种实现，把元素的class名字(gallery-wrapper)和添加到的位置(body)都写死了，这样不好，用户如果是想换个名字(以使用自己定义的css)，或者是想把元素添加到特定的元素下(而不是body)，就不能实现了。所以让用户可以通过配置控制元素的创建是明智之举：

```
// Retain an internal reference:
var wrapper = $( "<div />" )
    .attr( settings.wrapperAttrs )
    .appendTo( settings.container );
 
// Easy to reference later...
wrapper.append( "..." );
```

```
var defaults = {
    wrapperAttrs : {
        class: "gallery-wrapper"
    },
    // ... rest of settings ...
};
 
// We can use the extend method to merge options/settings as usual:
// But with the added first parameter of TRUE to signify a DEEP COPY:
var settings = $.extend( true, {}, defaults, options );
```

如果用户还有修改元素样式的需求的话，还可以暴露css的控制权：

```
var defaults = {
    wrapperCSS: {},
    // ... rest of settings ...
};
 
// Later on in the plugin where we define the wrapper:
var wrapper = $( "<div />" )
    .attr( settings.wrapperAttrs )
    .css( settings.wrapperCSS ) // ** Set CSS!
    .appendTo( settings.container );
```

### 提供回调能力
回调函数本质上就是过一段时间后被调用的函数，比如事件被触发的时候调用。通过接收用户提供的回调函数，插件可以在特定事件触发的时候通知用户执行他们需要的操作：

```
var defaults = {
 
    // We define an empty anonymous function so that
    // we don't need to check its existence before calling it.
    onImageShow : function() {},
 
    // ... rest of settings ...
 
};
 
// Later on in the plugin:
 
nextButton.on( "click", showNextImage );
 
function showNextImage() {
 
    // Returns reference to the next image node
    var image = getNextImage();
 
    // Stuff to show the image here...
 
    // Here's the callback:
    settings.onImageShow.call( image );
}
```

这里，使用`Function.prototype.call()`来调用回调函数，是为了把回调函数的this设置为当前的image元素。这样在回调函数中直接使用`$( this )`就可以操作这个图片了：

```
$( "ul.imgs li" ).superGallery({
    onImageShow: function() {
        $( this ).after( "<span>" + $( this ).attr( "longdesc" ) + "</span>" );
    },
 
    // ... other options ...
});
```

## 参考资料
- [How to Create a Basic Plugin | jQuery Learning Center](https://learn.jquery.com/plugins/basic-plugin-creation/)
- [Advanced Plugin Concepts | jQuery Learning Center](https://learn.jquery.com/plugins/advanced-plugin-concepts/)


