---
title: 关于JS访问器属性的一个案例
date: 2016-01-24 16:21:31
tags: [javascript]
---

当我在《javascript高级程序设计》中第一次看到`数据属性`和`访问器属性`时。觉得这个设计还是有点屌的，让每个属性又成了一个`对象`，这个对象里生命这个属性的特性。因为这种细化到属性级别的定制，使js的属性，这个基本元素变得强大，强大到可以做出别的语言做不出的效果，因为别的语言的属性的特性，是定死的，或者是通过少数修饰符(public,static)来进行修改。

这是好处，但是坏处也很明显。常规语言中，属性的行为是非常容易确定的。而js中，当你面对一个属性时，他有什么特性，是数据属性还是访问器属性，是数据属性的话，他可以更改吗？这些都是很难立马确定的。而且我估计目前的IDE也分析不出来。

不过书中也说了，这些都是为了实现js引擎用的，所以一般也用不到。

那你就打错特错了。想当初，我看到Java的书中说道：注解的使用的前提是，去掉注解也不会影响代码逻辑。所以注解一般用在像@Override这种没有也行有会更好的场景。但是，现实却完全不是如此。一个语言的特性一旦出来，就根本无法限制coder的使用了，于是你可以看到各种注解的高级用法。spring里为了减少xml配置，也是各种用注解。那些注解你删掉试试，绝逼跑不起来了。

说了这么多废话。其实是想说说今天使用JS访问器属性的一个例子。

和JYK讨论代码。我看到他把`xywh`这四个属性直接定义到base类里。我说咋不写个Rect类？他说，现在我直接`this.x`就行了。如果用上了Rect类，那还得`this.rect.x`。。。这个解释。。。我服

但是从设计的角度上来看，使用组合Rect类绝对是正确的做法，那如何既使用Rect又能够`this.x`呢？我想到了访问器属性。在Base类里定义一个x的访问器属性，让他返回`this.rect.x`，不就得了？

代码如下：

```
function Rect(x,y,w,h){
    for(i in Rect.names){
        this[Rect.names[i]] = arguments[i];
    }
}

Rect.names = ['x','y','w','h']; //for sampler code, not for readable code

function Base(rect){
    this.rect = rect;

    for(name of Rect.names){
        (function(_this,_name){
            Object.defineProperty(_this,_name,{
                get: function(){
                    return _this.rect[_name];
                },
                set: function(newValue){
                    _this.rect[_name] = newValue;
                }
            });
        })(this,name);
    }
    
}
```
