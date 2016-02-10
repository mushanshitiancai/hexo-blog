---
title: emacs配置prelude使用笔记
date: 2016-01-27 16:42:12
tags: [tools,emacs]
---

Perlude也算是emacs上一个很有名的配置的了，在github上有2000多的start。

## 安装

    curl -L https://github.com/bbatsov/prelude/raw/master/utils/installer.sh | sh

## 更新
更新插件：

    M-x package-list-packages RET U x

更新Perlude本身：

    cd ~/.emacs.d && git pull

## 开关模块
perlude包含了许多模块，但是默认并没有全部开启。模块配置文件在`~/.emacs.d/prelude-modules.el`中：

```
;; Emacs IRC client
(require 'prelude-erc)
(require 'prelude-ido) ;; Super charges Emacs completion for C-x C-f and more
;; (require 'prelude-helm) ;; Interface for narrowing and search
;; (require 'prelude-helm-everywhere) ;; Enable Helm everywhere
(require 'prelude-company)
;; (require 'prelude-key-chord) ;; Binds useful features to key combinations
;; (require 'prelude-mediawiki)
;; (require 'prelude-evil)

;;; Programming languages support
(require 'prelude-c)
;; (require 'prelude-clojure)
...
```

需要什么模块，去掉前面的注释就可以了。

## 配置文件
那我们需要在哪里添加我们自己的自定义配置呢？Perlude提供了一个`personal`目录。里面的所有elisp脚本都会被被调用

`personal/preload`中的所有elisp脚本会在Prelude开始前调用。

## Helm
默认，prelude不开启helm。

    (require 'prelude-helm-everywhere)

安装失败

    File error: https://melpa.org/packages/helm-ag-20160119.454.el, Not found

这是helm-ag模块安装失败了。目前原因不明，先把这个模块关闭吧，`.emacs.d/modules/prelude-helm-everywhere.el`：

```
;; (prelude-require-packages '(helm-descbinds helm-ag))  注释掉这一行
```


## 源码阅读笔记

load-file-name：
load-file-name is a variable defined in `C source code'.
Full name of file being loaded by `load'.

`load-file-name`保存当前被`load`读取的文件的路径

    (defvar prelude-dir (file-name-directory load-file-name)
        "The root dir of the Emacs Prelude distribution.")

这句定义了prelude的工作目录

expand-file-name：

add-to-list:如果列表中不存在该元素，添加到列表中


`.emacs.d/init.el`是配置的入口文件：

```
;;; init.el --- Prelude's configuration entry point.
(defvar current-user
      (getenv
       (if (equal system-type 'windows-nt) "USERNAME" "USER")))

(message "Prelude is powering up... Be patient, Master %s!" current-user)

(when (version< emacs-version "24.1")
  (error "Prelude requires at least GNU Emacs 24.1, but you're running %s" emacs-version))

;; Always load newest byte code
(setq load-prefer-newer t)

(defvar prelude-dir (file-name-directory load-file-name)
  "The root dir of the Emacs Prelude distribution.")
(defvar prelude-core-dir (expand-file-name "core" prelude-dir)
  "The home of Prelude's core functionality.")
(defvar prelude-modules-dir (expand-file-name  "modules" prelude-dir)
  "This directory houses all of the built-in Prelude modules.")
(defvar prelude-personal-dir (expand-file-name "personal" prelude-dir)
  "This directory is for your personal configuration.

Users of Emacs Prelude are encouraged to keep their personal configuration
changes in this directory.  All Emacs Lisp files there are loaded automatically
by Prelude.")
(defvar prelude-personal-preload-dir (expand-file-name "preload" prelude-personal-dir)
  "This directory is for your personal configuration, that you want loaded before Prelude.")
(defvar prelude-vendor-dir (expand-file-name "vendor" prelude-dir)
  "This directory houses packages that are not yet available in ELPA (or MELPA).")
(defvar prelude-savefile-dir (expand-file-name "savefile" prelude-dir)
  "This folder stores all the automatically generated save/history-files.")
(defvar prelude-modules-file (expand-file-name "prelude-modules.el" prelude-dir)
  "This files contains a list of modules that will be loaded by Prelude.")

(unless (file-exists-p prelude-savefile-dir)
  (make-directory prelude-savefile-dir))

(defun prelude-add-subfolders-to-load-path (parent-dir)
 "Add all level PARENT-DIR subdirs to the `load-path'."
 (dolist (f (directory-files parent-dir))
   (let ((name (expand-file-name f parent-dir)))
     (when (and (file-directory-p name)
                (not (string-prefix-p "." f)))
       (add-to-list 'load-path name)
       (prelude-add-subfolders-to-load-path name)))))

;; add Prelude's directories to Emacs's `load-path'
(add-to-list 'load-path prelude-core-dir)
(add-to-list 'load-path prelude-modules-dir)
(add-to-list 'load-path prelude-vendor-dir)
(prelude-add-subfolders-to-load-path prelude-vendor-dir)

;; reduce the frequency of garbage collection by making it happen on
;; each 50MB of allocated data (the default is on every 0.76MB)
(setq gc-cons-threshold 50000000)

;; warn when opening files bigger than 100MB
(setq large-file-warning-threshold 100000000)

;; preload the personal settings from `prelude-personal-preload-dir'
(when (file-exists-p prelude-personal-preload-dir)
  (message "Loading personal configuration files in %s..." prelude-personal-preload-dir)
  (mapc 'load (directory-files prelude-personal-preload-dir 't "^[^#].*el$")))

(message "Loading Prelude's core...")

;; the core stuff
(require 'prelude-packages)
(require 'prelude-custom)  ;; Needs to be loaded before core, editor and ui
(require 'prelude-ui)
(require 'prelude-core)
(require 'prelude-mode)
(require 'prelude-editor)
(require 'prelude-global-keybindings)

;; OSX specific settings
(when (eq system-type 'darwin)
  (require 'prelude-osx))

(message "Loading Prelude's modules...")

;; the modules
(if (file-exists-p prelude-modules-file)
    (load prelude-modules-file)
  (message "Missing modules file %s" prelude-modules-file)
  (message "You can get started by copying the bundled example file"))

;; config changes made through the customize UI will be store here
(setq custom-file (expand-file-name "custom.el" prelude-personal-dir))

;; load the personal settings (this includes `custom-file')
(when (file-exists-p prelude-personal-dir)
  (message "Loading personal configuration files in %s..." prelude-personal-dir)
  (mapc 'load (directory-files prelude-personal-dir 't "^[^#].*el$")))

(message "Prelude is ready to do thy bidding, Master %s!" current-user)

(prelude-eval-after-init
 ;; greet the use with some useful tip
 (run-at-time 5 nil 'prelude-tip-of-the-day))

;;; init.el ends here
```

入口文件中，第一个require的是`prelude-packages`。

```
;;; prelude-packages.el --- Emacs Prelude: default package selection.
(require 'cl)
(require 'package)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
;; set package-user-dir to be relative to Prelude install path
(setq package-user-dir (expand-file-name "elpa" prelude-dir))
(package-initialize)

;; 定义需要安装的插件列表
(defvar prelude-packages
  '(ace-window
    avy
    anzu
    beacon
    browse-kill-ring
    dash
    discover-my-major
    diff-hl
    diminish
    easy-kill
    epl
    expand-region
    flycheck
    gist
    git-timemachine
    gitconfig-mode
    gitignore-mode
    god-mode
    grizzl
    guru-mode
    ov
    projectile
    magit
    move-text
    operate-on-number
    smart-mode-line
    smartparens
    smartrep
    undo-tree
    volatile-highlights
    zenburn-theme
    )
  "A list of packages to ensure are installed at launch.")

;; 判断插件列表中的插件是否都安装完毕
(defun prelude-packages-installed-p ()
  "Check if all packages in `prelude-packages' are installed."
  (every #'package-installed-p prelude-packages))

(defun prelude-require-package (package)
  "Install PACKAGE unless already installed."
  (unless (memq package prelude-packages)
    (add-to-list 'prelude-packages package))
  (unless (package-installed-p package)
    (package-install package)))

(defun prelude-require-packages (packages)
  "Ensure PACKAGES are installed.
Missing packages are installed automatically."
  (mapc #'prelude-require-package packages))

(define-obsolete-function-alias 'prelude-ensure-module-deps 'prelude-require-packages)

(defun prelude-install-packages ()
  "Install all packages listed in `prelude-packages'."
  (unless (prelude-packages-installed-p)
    ;; check for new packages (package versions)
    (message "%s" "Emacs Prelude is now refreshing its package database...")
    (package-refresh-contents)
    (message "%s" " done.")
    ;; install the missing packages
    (prelude-require-packages prelude-packages)))

;; run package installation
(prelude-install-packages)

(defun prelude-list-foreign-packages ()
  "Browse third-party packages not bundled with Prelude.

Behaves similarly to `package-list-packages', but shows only the packages that
are installed and are not in `prelude-packages'.  Useful for
removing unwanted packages."
  (interactive)
  (package-show-package-list
   (set-difference package-activated-list prelude-packages)))

(defmacro prelude-auto-install (extension package mode)
  "When file with EXTENSION is opened triggers auto-install of PACKAGE.
PACKAGE is installed only if not already present.  The file is opened in MODE."
  `(add-to-list 'auto-mode-alist
                `(,extension . (lambda ()
                                 (unless (package-installed-p ',package)
                                   (package-install ',package))
                                 (,mode)))))

(defvar prelude-auto-install-alist
  '(("\\.clj\\'" clojure-mode clojure-mode)
    ("\\.cmake\\'" cmake-mode cmake-mode)
    ("CMakeLists\\.txt\\'" cmake-mode cmake-mode)
    ("\\.coffee\\'" coffee-mode coffee-mode)
    ("\\.css\\'" css-mode css-mode)
    ("\\.csv\\'" csv-mode csv-mode)
    ("\\.d\\'" d-mode d-mode)
    ("\\.dart\\'" dart-mode dart-mode)
    ("\\.elm\\'" elm-mode elm-mode)
    ("\\.ex\\'" elixir-mode elixir-mode)
    ("\\.exs\\'" elixir-mode elixir-mode)
    ("\\.elixir\\'" elixir-mode elixir-mode)
    ("\\.erl\\'" erlang erlang-mode)
    ("\\.feature\\'" feature-mode feature-mode)
    ("\\.go\\'" go-mode go-mode)
    ("\\.groovy\\'" groovy-mode groovy-mode)
    ("\\.haml\\'" haml-mode haml-mode)
    ("\\.hs\\'" haskell-mode haskell-mode)
    ("\\.json\\'" json-mode json-mode)
    ("\\.kv\\'" kivy-mode kivy-mode)
    ("\\.latex\\'" auctex LaTeX-mode)
    ("\\.less\\'" less-css-mode less-css-mode)
    ("\\.lua\\'" lua-mode lua-mode)
    ("\\.markdown\\'" markdown-mode markdown-mode)
    ("\\.md\\'" markdown-mode markdown-mode)
    ("\\.ml\\'" tuareg tuareg-mode)
    ("\\.pp\\'" puppet-mode puppet-mode)
    ("\\.php\\'" php-mode php-mode)
    ("\\.proto\\'" protobuf-mode protobuf-mode)
    ("\\.pyd\\'" cython-mode cython-mode)
    ("\\.pyi\\'" cython-mode cython-mode)
    ("\\.pyx\\'" cython-mode cython-mode)
    ("PKGBUILD\\'" pkgbuild-mode pkgbuild-mode)
    ("\\.rs\\'" rust-mode rust-mode)
    ("\\.sass\\'" sass-mode sass-mode)
    ("\\.scala\\'" scala-mode2 scala-mode)
    ("\\.scss\\'" scss-mode scss-mode)
    ("\\.slim\\'" slim-mode slim-mode)
    ("\\.styl\\'" stylus-mode stylus-mode)
    ("\\.swift\\'" swift-mode swift-mode)
    ("\\.textile\\'" textile-mode textile-mode)
    ("\\.thrift\\'" thrift thrift-mode)
    ("\\.yml\\'" yaml-mode yaml-mode)
    ("\\.yaml\\'" yaml-mode yaml-mode)
    ("Dockerfile\\'" dockerfile-mode dockerfile-mode)))

;; markdown-mode doesn't have autoloads for the auto-mode-alist
;; so we add them manually if it's already installed
(when (package-installed-p 'markdown-mode)
  (add-to-list 'auto-mode-alist '("\\.markdown\\'" . gfm-mode))
  (add-to-list 'auto-mode-alist '("\\.md\\'" . gfm-mode)))

(when (package-installed-p 'pkgbuild-mode)
  (add-to-list 'auto-mode-alist '("PKGBUILD\\'" . pkgbuild-mode)))

;; build auto-install mappings
(mapc
 (lambda (entry)
   (let ((extension (car entry))
         (package (cadr entry))
         (mode (cadr (cdr entry))))
     (unless (package-installed-p package)
       (prelude-auto-install extension package mode))))
 prelude-auto-install-alist)

(provide 'prelude-packages)
;; Local Variables:
;; byte-compile-warnings: (not cl-functions)
;; End:

;;; prelude-packages.el ends here

```











