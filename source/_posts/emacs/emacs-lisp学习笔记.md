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

defvar和setq的区别：
1. defvar只对未赋值的变量赋值
2. defvar可以对变量设置文档字符串

> The defvar special form is similar to setq in that it sets the value of a variable. It is unlike setq in two ways: first, it only sets the value of the variable if the variable does not already have a value. If the variable already has a value, defvar does not override the existing value. Second, defvar has a documentation string.
> [Programming in Emacs Lisp: defvar](http://www.gnu.org/software/emacs/manual/html_node/eintr/defvar.html)



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
- `(interactive "n")`，命令需要一个数字，提示字符串可以跟在n后面
- `(interactive "s")`，命令需要一个字符串，提示字符串可以跟在s后面
- `(interactive "r")`，命令需要2个参数，分别代表选区的开始和结束点

## emacs常用函数
编写emacs插件，除了elisp本身外，还需要使用emacs提供的许多API。API是通用称呼，emacs对外的API就是一系列的函数。

### 光标位置

```
;; 获取光标位置。第一个字符的位置为1
(point)

;; 获取选区的开始结束位置
(region-beginning)
(region-end)

;; 获取行的开始结束位置
(line-beginning-position)
(line-end-position)

;; 获取buffer第一个字符和最后一个字符的位置
(point-min)
(point-max)
```

### 移动光标

```
;; 移动光标到指定位置
(goto-char 392)

;; 移动几个字符
(forward-char n)
(backward-char n)

;; 移动到目标字符串的位置
(search-forward myStr) ; end of myStr
(search-backward myStr) ; beginning of myStr

;; 移动到目标字符串（使用正则表达式）
(re-search-forward myRegex)
(re-search-backward myRegex)

;; 移动光标到第一个非a-z字符
(skip-chars-forward "a-z")
(skip-chars-backward "a-z")
```

### 删除、插入、修改文本

```
;; 删除9个字符
(delete-char 9)

;; 删除选区中的字符
(delete-region myStartPos myEndPos)

;; 插入字符
(insert "i ♥ cats")

;; 获取选区中的字符
(setq myStr (buffer-substring myStartPos myEndPos))

;; 选区中的字符改为大写
(capitalize-region myStartPos myEndPos)
```

### 字符串相关

```
;; 获取字符串长度
(length "abc") ; returns 3

;; 获取子串
(substring myStr startIndex endIndex)

;; 使用正则表达式修改字符串中的文本
(replace-regexp-in-string myRegex myReplacement myStr)
```

### buffer相关

```
;; 获取buffer的名字
(buffer-name)

;; buffer打开的文件的名字
(buffer-file-name)

;; 切换buffer
(set-buffer myBufferName)

;; 保存buffer
(save-buffer)

;; 关闭buffer
(kill-buffer myBufferName)

;; 暂时地指定一个buffer为当前修改的buffer
(with-current-buffer myBufferName
  ;; 执行操作
)
```

### 文件相关

```
;; 打开文件
(find-file myPath)

;; 另存为buffer。关闭原来的buffer，打开另存为的文件到新buffer中
(write-file myPath)

;; 插入文件内容到光标位置
(insert-file-contents myPath)

;; 最近选区内容到文件尾
(append-to-file myStartPos myEndPos myPath)

;; 重命名文件
(rename-file fileName newName)

;; 复制文件
(copy-file oldName newName)

;; 删除文件
(delete-file fileName)

;; 获取文件所在的目录
(file-name-directory myFullPath)

;; 获取路径文件名部分
(file-name-nondirectory myFullPath)

;; 获取扩展名部分
(file-name-extension myFileName)

;; 获取非扩展名部分
(file-name-sans-extension myFileName)
```

## 查看函数、变量文档
`C-h f` `describe-function` 查看函数文档
`C-h v` `describe-variable` 查看变量文档

`C-h a` `apropos-command` 查看命令说明
`apropos-variable` 查看变量名说明？
`apropos-value`    查看变量值说明？

`elisp-index-search`
`emacs-index-search`
在elisp、emacs文档中搜索

## elisp编程的一些配置
默认的`Lisp Interaction`不会高亮匹配括号。可以开启`(show-paren-mode 1)`来高亮匹配的括号。

```
(setq show-paren-style 'parenthesis) ; 高亮括号

(setq show-paren-style 'expression) ; 高亮真个s表达式

(setq show-paren-style 'mixed) ; 如果有括号高亮括号，否则高亮整个表达式
```


## 参考文章
- [Practical Emacs Lisp][Practical Emacs Lisp]
- [GNU Emacs Lisp Reference Manual: Top](https://www.gnu.org/software/emacs/manual/html_node/elisp/)

[Practical Emacs Lisp]: http://ergoemacs.org/emacs/elisp.html