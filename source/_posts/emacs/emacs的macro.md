---
title: 【TODO】emacs的macro
date: 2016-02-18 10:19:49
tags: [emacs]
---

lisp的宏使你可以定义新的控制流程和其他语言特性。宏的定义特别像函数，但是函数是告诉解释器如何计算一个值，而宏则是告诉解释器如何计算出另外一个lisp表达式。我们称这个表达式为这个宏的展开。

宏之所以可以做到这些，是因为宏可以在未求值的lisp表达式上操作，而函数只能在参数的值上操作（函数的参数总是会先被求值）。所以宏可以构建包含参数的表达式。

如果你只是为了速度的目的而使用宏替代函数，可以考虑使用`inline function`。

## 简单的例子
假设我们想要通过宏实现自增。我们可以这么写：

```
(defmacro inc (var)
   (list 'setq var (list '1+ var)))
```

当我们通过`(inc x)`这种形式调用这个宏，参数`var`的值是`x`——注意，是`x`本身，而不是`x`的值。这个宏使用`var`来构造表达式`(setq x (1+ x))`。一旦macro返回这个表达式，lisp会继续执行他，最终效果是，x自增了。

## 测试一个对象是否是宏

    函数：macrop object

## 宏展开
宏调用和函数调用很像，list的第一个元素为宏，即为宏调用。剩下的部分是宏的参数。

在执行初期，宏和函数只有一个区别，就是宏的参数不会被求值。和``

宏和函数的第二个区别是，宏返回的是一个lisp表达式，lisp解释器会在表达式返回后立马执行。

因为宏展开会以普通方式执行，所以宏中可以调用其他宏，甚至他可以调用自身，虽然这很不常见。

注意，Emacs会在读取一个未编译的lisp文件时尝试去展开宏，但这并不总是成功的。如果可以展开，就可以加速之后的执行。[How Programs Do Loading](http://www.gnu.org/software/emacs/manual/html_node/elisp/How-Programs-Do-Loading.html#How-Programs-Do-Loading)

你可以使用`macroexpand`来查看宏的展开。

    函数：macroexpand form &optional environment

如果`form`是一个宏，这个函数会展开他。如果结果是另外一个宏，他会继续展开，知道结果不是一个宏为止，然后返回。如果`form`不是宏，`macroexpand`会直接返回他。

注意`macroexpand`不会展开子表达式。及时宏调用了自身，也不会去展开他。

`macroexpand`也不会去展开`inline function`。

## 宏和字节编译
TODO

## 定义宏
宏对象是一个`CAR`为`macro`，并且`CDR`为function的list。展开宏是通过在函数上应用（通过apply）未求值的参数list。

可以像匿名函数一样使用匿名宏，但是这是无法实现的，因为无法无法传递匿名宏给`mapcar`这样的功能。实践中，所有宏都有名字，并且都是用`defmacro`这个宏定义的。

    宏：defmacro name args [doc] [declare] body…

`defmacro`用类似`(macro lambda args . body)`这种形式定义宏，并绑定到`name`上。

注意list的`CDR`是一个lambda表达式。在`args`中可以使用`&rest`和`&optional`。`name`和`args`都不需要quote。

`doc`是macro的文档字符串。`declare`用来指定macro的元数据。([Declare Form](http://www.gnu.org/software/emacs/manual/html_node/elisp/Declare-Form.html#Declare-Form))。注意宏不能有`interactive`申明，因为宏不能通过命令的方式调用。

宏经常需要构造很大的list，其中包含原始list和求值的部分。为了方便书写，可以使用`\``语法。([Backquote](http://www.gnu.org/software/emacs/manual/html_node/elisp/Backquote.html#Backquote))，比如：

```
(defmacro t-becomes-nil (variable)
  `(if (eq ,variable t)
       (setq ,variable nil)))
(t-becomes-nil foo)
     ≡ (if (eq foo t) (setq foo nil))
```

## 使用宏的普遍问题
//TODO

## 宏缩进？
//TODO



## 参考文章
- [GNU Emacs Lisp Reference Manual: Macros](http://www.gnu.org/software/emacs/manual/html_node/elisp/Macros.html#Macros)
