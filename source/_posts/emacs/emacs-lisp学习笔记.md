---
title: emacs lisp学习笔记
date: 2016-01-28 14:53:34
tags: [emacs]
---

为了定制emacs，emacs lisp不能不学。既能学习一门新的语言，又能更随心所欲地定制emacs，何乐不为。

本文为阅读[Practical Emacs Lisp][Practical Emacs Lisp]的读书笔记。

## 学习环境
emacs lisp最好的开发环境就是emacs，因为这里就是他的运行环境。

默认打开emacs会包含一个`*scratch*`buffer，这个buffer默认就是Lisp Interaction mode，可以用来执行lisp脚本。

在这个buffer中输入`(+ 1 2)`，这是emacs种最简单的表达式，有许多种方法执行他：
- `C-j` `eval-print-last-sexp` 执行光标前的S表达式，并输出到当前buffer
- `C-x C-e` `eval-last-sexp` 执行光标前的S表达式，把值输出到echo area(屏幕下边)
- `C-M-x` `eval-defun` valuate the top-level form containing point, or after point.

我个人比较喜欢使用`C-M-x`，因为不用把鼠标移到表达式后。

## 输出

```
(message "hello world")
"hello world"
(message "print number %d" 100)
"print number 100"
(message "print %s" "string")
"print string"
(message "print list %S" (list 1 2 3))
"print list (1 2 3)"
```

## 算数函数

lisp使用的是中缀表达式，所以写起来会比较奇怪。而lisp的精髓也就是这S表达式了。

```
(+ 1 2)
3
(+ 1 2 3)
6
(/ 7 2)
3
(/ 7 2.0)
3.5
(% 7 4)
3
(expt 2 3)
8
```

判断数据类型：

```
(integerp 1)
t
(integerp 1.) ;; 1.是一个整数
t
(integerp 1.0)
nil
(floatp 1.0)
t
```

p结尾的函数表示返回true或者false的函数，p指的是`predicate`。

字符串和数字互转：

```
(string-to-number "3")
3
(number-to-string 3)
"3"
```

## True和False
在elisp中，`nil`表示false，其他的非nil的指都是true。

注意：
- `nil`和空list`()`等价，所以`()`也是false
- `0`是true
- `""`是true

为了表示方便，标示符`t`用来

## 布尔函数

逻辑关系：

```
(and t nil)
nil
(or t nil)
t
(not t)
nil
```

相等关系：

```
(< 1 2)
t
(> 1 2)
nil
(>= 1 2)
nil
(<= 1 2)
t
(= 3 3)
t
(= 3 3.0)
t
(/= 3 4)               ;;elisp的不等于的写法比较特殊。不等于只能用于数字。
t
(string-equal "a" "a") ;;/=只能用于比较数字，比较字符串需要使用string-equal
t
(equal 1 "1")          ;;equal是更通用的比较，但是需要两者数据类型和值都一样
nil
(equal 1 1)
t
(equal 1 1.0)          ;;这个不一样是因为数据类型不一样
nil
```

奇偶关系，没有原生函数：

```
(= (% 8 2) 0)  ;;偶数
t
(= (% 8 2) 1)  ;;奇数
nil
```

## 变量
全局变量：

```
(setq  x 1)          ;; 把1付给q
1
(setq a 1 b 2 c 3)   ;; 把123付给abc
3
```

## 条件语句

```
;;if的结构是`(if test true_body false_body)`，注意每个body都是一个表达式。
(if (= 1 1) "equal" "not equal")
"equal"

;;如果逻辑超过一个表达式，可以使用progn把多个表达式组织成一个表达式
(if (= 1 1) (progn (message "hello") (message "world")))
"world"

;;如果不需要else子句，可以使用when
;;(when test expr1 expr2 …)相当于(if test (progn expr1 expr2 …))
(when (= 1 1) (message "hello") (+ 1 2))
3
```

## 块语句

    (progn (message "a") (message "b"))

把多个表达式组合成一个表达式，上面已经提到了。progn返回最后表达式的值。

## 循环语句

```
(setq x 0)
0
(while (< x 4)
  (print (format "%d" x))
  (setq x (1+ x)))
"0"
"1"
"2"
"3"
nil
```

white返回的一定是nil

## 函数
定义函数的格式如下：

    (defun function_name (param1 param2 …) "doc_string" body)

```
(defun add (a b)
  (+ a b))
(add 2 3)
5
```

普通函数是无法作为命令(command)调用的，如果你想使用`M-x`(`execute-extended-command`)来调用你的函数，可以这么写：

```
(defun say ()
  (interactive)
  (message "hello"))
```

如果函数需要参数，可以这么写，然后通过`C-u 1 M-x say`来调用：

```
(defun say (name)
  (interactive "p")
  (message "hello %s" name))
```

调用了`interactive`函数的函数有两个特点：
1. 函数可以通过`M-x`调用，也就是说函数是一个命令了
2. 传给`interactive`的参数，告诉emacs如何给这个函数传递参数

第二点有这些常见的用法：
- `(interactive)`，命令不需要参数
- `(interactive "n")`，命令需要一个数字
- `(interactive "s")`，命令需要一个字符串
- `(interactive "r")`，命令需要2个参数，分别代表选区的开始和结束点

- [Practical Emacs Lisp][Practical Emacs Lisp]
- [GNU Emacs Lisp Reference Manual: Top](https://www.gnu.org/software/emacs/manual/html_node/elisp/)

[Practical Emacs Lisp]: http://ergoemacs.org/emacs/elisp.html