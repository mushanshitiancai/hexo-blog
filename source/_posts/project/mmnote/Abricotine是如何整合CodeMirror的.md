---
title: Abricotine是如何整合CodeMirror的
date: 2017-01-07 20:33:05
categories:
tags: [mmnote]
---

Abricotine是一款支持Inline Preview的markdown编辑器。同时也是基于Electron的编辑器。所以我打算好好参考其代码，尤其是学习他是如何做到编辑时预览图片的。

![](/img/abricotine.png)

Abricotine（下文简称A）采用Application-Window-Document的设计。一个应用有多个窗口，每个窗口打开一个文档。所以初始化CodeMirror（下面简称CM）的时机是初始化AbrDocument类的时候。

AbrDocument中引用了cm-init.js，真正的初始化代码在其中：

```js
/*
*   Abricotine - Markdown Editor
*   Copyright (c) 2015 Thomas Brouard
*   Licensed under GNU-GPLv3 <http://www.gnu.org/licenses/gpl.html>
*/

var remote = require("electron").remote,
    constants = remote.require("./constants.js"),
    glob = require("glob"),
    pathModule = require("path");

// 1.1 加载插件代码
function batchRequire (cwd, pattern, cbSingle, cbAll) {
    glob(pattern, { cwd: cwd }, function (err, files) {
        if (err !== null) {
            console.error("Glob error");
            return;
        }
        var modPath,
            promises = [],
            getAPromise = function (modPath, callback) {
                return new Promise (function (resolve, reject) {

                    // 加载插件模块,这里直接用require感觉也可以吧
                    var mod = require.main.require(modPath);
                    if (typeof callback === "function") {
                        callback(mod, modPath);
                    }
                    resolve(mod);
                });
            };
        for(var i=0; i<files.length; i++){
            modPath = pathModule.join(__dirname, files[i]);
            promises.push(getAPromise(modPath, cbSingle));
        }

        // 使用Promise.all来同时执行所有加载任务，全部完成后调用cbAll
        Promise.all(promises).then(cbAll);
    });
}


// 1. 载入自定义的CM插件
function extendCodeMirror () {
    return new Promise ( function (resolve, reject) {
        var cwd = pathModule.join(constants.path.app, "/app/renderer/"),
            
            // 使用glob来指定那些文件是插件文件
            pattern = "cm-extend-*.js",

            // 加载完一个插件后的回调
            callbackSingle = function (mod, modPath) {
                if (typeof mod === "function") {
                    
                    // 注册插件 
                    mod(CodeMirror);
                } else {
                    throw new Error("Module " + modPath + " is not a valid CodeMirror extension");
                }
            };

        // resolve是全部加载完毕后的回调
        batchRequire(cwd, pattern, callbackSingle, resolve);
    });
}

function defineAbrMode (CodeMirror, newModeName, baseMode) {
    CodeMirror.defineMode(newModeName, function (config) {
        return CodeMirror.multiplexingMode(
            CodeMirror.getMode(config, baseMode),
            // Disable commented $
            {open: "\\$", close: " ",
             mode: CodeMirror.getMode(config, "text/plain")},
            // Maths
            {open: "$$", close: "$$",
             mode: CodeMirror.getMode(config, "text/x-latex")}
            // .. more multiplexed styles can follow here
        );
    });
}

// 2. 加载插件完毕后，初始化CodeMirror
function initCodeMirror () {
    return new Promise ( function (resolve, reject) {
        // Spelling and no-spelling modes shortcuts
        defineAbrMode(CodeMirror, "abr-spellcheck-off", {
            name: "gfm",
            highlightFormatting: true
        });
        defineAbrMode(CodeMirror, "abr-spellcheck-on", "spellchecker");

        var options = {
            theme: "", // Disable CodeMirror themes
            addModeClass: true, // Used to disable colors on markdow lists (cm-variable-2, cm-variable-3, cm-keyword) but keep it in other modes
            lineNumbers: false,
            lineWrapping: true,
            autofocus: true,
            autoCloseBrackets: false,
            scrollbarStyle: "overlay",
            mode: "abr-spellcheck-off",
            // TODO: replace default keymap by a custom one which removes most of hotkeys (CodeMirror interferences with menu accelerators)
            extraKeys: {
                "Enter": "newlineAndIndentContinueMarkdownList",
                "Home": "goLineLeft",
                "End": "goLineRight",
                "Ctrl-Up": "goPrevParagraph",
                "Ctrl-Down": "goNextParagraph"
            }
        };

        // Start editor
        var cm = CodeMirror.fromTextArea(document.getElementById("cm"), options);

        // Adding custom overlays
        // Strike checked list items
        cm.addOverlay({
            token: function(stream) {
                if (stream.match(/^\* \[x\].*/)) {
                    return "checked-list-item";
                }
                stream.match(/^\s*\S*/);
                return null;
            }
        });
        // Add trailing whitespaces
        cm.addOverlay({
            token: function(stream) {
                if (stream.match(/^\s\s+$/)) {
                    return "trailing-whitespace";
                }
                stream.match(/^\s*\S*/);
                return null;
            }
        });
        // (Not) Blank lines (show-blocks option)
        cm.addOverlay({
            token: function(stream) {
                stream.match(/^\s*\S*/);
                return "line-not-blank";
            }
        });
        resolve(cm);
    });
}

module.exports = function (callback) {
    extendCodeMirror().then(initCodeMirror).then(callback);
};
```

这里的每个操作都是返回Promise的。主要的步骤：

1. 加载自定义CodeMirror插件
2. 初始化CodeMirror

Abricotine实现Autopreview都是在插件中实现的，我们来看看具体代码：

```js
/*
*   Abricotine - Markdown Editor
*   Copyright (c) 2015 Thomas Brouard
*   Licensed under GNU-GPLv3 <http://www.gnu.org/licenses/gpl.html>
*/

// Autopreview for CodeMirror

var path = require("path"),
    isUrl = require("is-url"),
    parsePath = require("parse-filepath");

function autopreview (cm, line, types) {

    function lineIsSelected (lineNumber) {
        // FIXME: doesnt work in case of multiple selection
        var cursor = {
            begin: doc.getCursor("from"),
            end: doc.getCursor("to")
        };
        return !(cursor.begin.line > lineNumber || cursor.end.line < lineNumber);
    }

    // 预览的核心函数
    // 行内预览本质上是把符合正则的字符串替换为对应的DOM元素
    function replaceInLine (line, typeConfig) {
        var lineNumber,
            regex = typeConfig.regex,
            match,
            from,
            to,
            element,
            markOptions = typeConfig.marker,
            textMarker;
        if (typeof line === 'number') {
            lineNumber = line;
            line = doc.getLineHandle(line);
        } else {
            lineNumber = doc.getLineNumber(line);
        }
        if (lineIsSelected(lineNumber)){ return; }
        while ((match = regex.exec(line.text)) !== null) {
            from = {
                line: lineNumber,
                ch: match.index
            };
            to = {
                line: lineNumber,
                ch: from.ch + match[0].length
            };
            // 如果已经设置了mark，则不再设置
            if (doc.findMarks(from, to).length > 0) {
                continue;
            }
            // 新建对应的DOM元素，比如图片就是img
            element = typeConfig.createElement(match);
            if (!element) {
                continue;
            }

            // 使用doc.markText添加mark
            markOptions.replacedWith = element;
            textMarker = doc.markText(from, to, markOptions);
            if (typeConfig.callback && typeof typeConfig.callback === "function" && textMarker && element) {
                typeConfig.callback(textMarker, element);
            }
        }
    }

    var doc = cm.doc,
        config = {
            image: {
                regex: /!\[([^\]]*)\]\(([\(\)\[\]-a-zA-Z0-9@:%_\+~#=\.\\\/ ]+\.(jpg|jpeg|png|gif|svg))(\s("|')([-a-zA-Z0-9@:%_\+~#=\.\/! ]*)("|')\s?)?\)/gi,
                createElement: function (match) {
                    function getImageUrl (href) {
                        if (isUrl(href)) {
                            return href;
                        }
                        var parsedPath = parsePath(href);
                        if (parsedPath.isAbsolute) {
                            return parsedPath.absolute;
                        } else {
                            return path.join(process.cwd(), href);
                        }
                    }
                    var alt = match[1] || '',
                        url = getImageUrl(match[2]),
                        title = match[6],
                        $element = $("<img class='autopreview-image'>").attr("src", url).attr("alt", alt);
                    if (title) {
                        $element.attr("title", title);
                    }
                    return $element.get(0);
                },
                // markText的参数
                marker: {
                    clearOnEnter: false,
                    handleMouseEvents: true,
                    inclusiveLeft: true,
                    inclusiveRight: true
                },
                callback: function (textMarker, element) {
                    var onclickFunc = function() {
                        var pos = textMarker.find().to;
                        textMarker.clear();
                        cm.doc.setCursor(pos);
                        cm.focus();
                    };
                    textMarker.on("beforeCursorEnter", function () {
                        if (!doc.somethingSelected()) { // Fix blink on selection
                            textMarker.clear();
                        }
                    });
                    element.addEventListener("load", function() {
                        textMarker.changed();
                    }, false);
                    element.onerror = function() {
                        $(element).replaceWith("<span class='autopreview-image image-error'></span>");
                        element.onclick = onclickFunc;
                        textMarker.changed();
                    };
                    element.onclick = onclickFunc;
                }
            },
            todolist: {
                regex: /^(\*|-|\+)\s+\[(\s*|x)?\]\s+/g,
                createElement: function (match) {
                    var isChecked = match[2] === "x",
                        checkedClass = isChecked ? " checked" : "",
                        $element = $("<span class='autopreview-todolist todolist" + checkedClass +"'></span>");
                    return $element.get(0);
                },
                marker: {
                    clearOnEnter: true,
                    handleMouseEvents: false,
                    inclusiveLeft: true,
                    inclusiveRight: true
                },
                callback: function (textMarker, element) {
                    var $element = $(element);
                    $element.click( function () {
                        var pos = textMarker.find(),
                            isChecked = $(this).hasClass("checked"),
                            newText = isChecked ? "* [] " : "* [x] ";
                        doc.replaceRange(newText, pos.from, pos.to);
                        $(this).toggleClass("checked");
                    });
                }
            },
            iframe: {
                regex: /^\s*<iframe[^<>]*src=["'](https?:\/\/(?:www\.)?([-a-zA-Z0-9@:%_\+~#=\.! ]*)[-a-zA-Z0-9@:%_\+~#=\.\/!?&; ]*)["'][^<>]*>\s*<\/iframe>\s*$/gi,
                createElement: function (match) {
                    function isAllowed(domain) {
                        if (cm.getOption("autopreviewSecurity") === false) {
                            return true;
                        }
                        var whitelist = cm.getOption("autopreviewAllowedDomains") || [];
                        for (var i=0; i<whitelist.length; i++) {
                            if (domain !== whitelist[i] && domain.slice(-(whitelist[i] + 1)) !== "." + whitelist[i]) {
                                continue;
                            }
                            return true;
                        }
                        return false;
                    }
                    var url = match[1],
                        domain = match[2].trim();
                    if (!isAllowed(domain)) {
                        return false;
                    }
                    // Preserve iframe aspect ratio: http://fettblog.eu/blog/2013/06/16/preserving-aspect-ratio-for-embedded-iframes/
                    var widthRegex = /width\s*(?:=|:)\s*(?:'|")?(\d+)(?!\s*%)(?:\s*px)?(?:'|"|\s|>)/i,
                        heightRegex = /height\s*(?:=|:)\s*(?:'|")?(\d+)(?!\s*%)(?:\s*px)?(?:'|"|\s|>)/i,
                        iframeWidth = match[0].match(widthRegex),
                        iframeHeight = match[0].match(heightRegex),
                        aspectRatio = iframeWidth && iframeHeight ? parseInt((iframeHeight[1] / iframeWidth[1]) * 100) : 56;
                    aspectRatio = aspectRatio > 100 ? 100 : aspectRatio;
                    // Create element
                    var $parent = $("<div class='autopreview-iframe' style='padding-bottom: " + aspectRatio + "%;'></div>"),
                        $webview = $("<webview frameborder='0' src='" + url + "'></webview>"),
                        errorFunc = function () {
                            $webview.remove();
                            $parent.addClass("iframe-error");
                        };
                    $webview.appendTo($parent);
                    $webview.on("did-fail-load", errorFunc);
                    $webview.on("did-start-loading", function () {
                        var timeoutDelay = 10000;
                        setTimeout(function() {
                            var webview = $webview.get(0);
                            if (webview && document.body.contains(webview) && webview.isWaitingForResponse()) {
                                webview.stop();
                                errorFunc() ;
                            }
                        }, timeoutDelay);
                    });
                    $webview.on("did-stop-loading", function () {
                        $parent.addClass("iframe-loaded");
                    });
                    return $parent.get(0);
                },
                marker: {
                    clearOnEnter: false,
                    inclusiveLeft: false,
                    inclusiveRight: false
                },
                callback: function (textMarker, element) {
                    textMarker.on("beforeCursorEnter", function () {
                        if (!doc.somethingSelected()) { // Fix blink on selection
                            textMarker.clear();
                        }
                    });
                    element.onclick = function() {
                        if (!element.classList.contains("iframe-loaded")) {
                            var pos = textMarker.find().to;
                            textMarker.clear();
                            cm.doc.setCursor(pos);
                            cm.focus();
                        }
                    };
                }
            },
            anchor: {
                regex: /<a\s+name=["']([-a-zA-Z0-9@%_\+~#=!]+)["']\s*(\/>|>\s*<\/a>)/gi,
                createElement: function (match) {
                    var $element = $("<span class='anchor autopreview-anchor'><i class='fa fa-anchor'></i></span>");
                    return $element.get(0);
                },
                marker: {
                    clearOnEnter: true,
                    handleMouseEvents: true,
                    inclusiveLeft: true,
                    inclusiveRight: true
                }
            },
            math: {
                regex: /\${2}[^$]+\${2}/gi,
                createElement: function (match) {
                    var $element = $("<span class='math autopreview-math'>" + match[0] + "</span>");
                    return $element.get(0);
                },
                marker: {
                    clearOnEnter: false,
                    handleMouseEvents: true,
                    inclusiveLeft: true,
                    inclusiveRight: true
                },
                callback: function (textMarker, element) {
                    var onMathLoaded = function () {
                        textMarker.changed();
                    };
                    window.MathJax.Hub.Queue(["Typeset", window.MathJax.Hub, element], [onMathLoaded, undefined]);
                    textMarker.on("beforeCursorEnter", function () {
                        if (!doc.somethingSelected()) { // Fix blink on selection
                            textMarker.clear();
                        }
                    });
                }
            }
        };
    if (types === undefined || types.length === 0) {
        return;
    }
    for (var type in types) {
        if (types[type] === true && config[type]) {
            replaceInLine(line, config[type]);
        }
    }
}

module.exports = function (CodeMirror) {
    // 添加了两个autopreview用到的配置
    CodeMirror.defineOption("autopreviewSecurity", true);
    CodeMirror.defineOption("autopreviewAllowedDomains", []);

    // 这里没有使用CM提供的defineExtension，但本质上是一样的。
    CodeMirror.prototype.autopreview = function (line, types) {
        return autopreview (this, line, types);
    };
};
```

实时预览的核心是调用`doc.markText`来标记字符串。`doc.markText`的用法，我在《CodeMirror使用笔记》有说明。

那这个autopreview插件是如何使用的呢？

```js
// abr-document.js

autopreview: function (types, lines) {
    var cm = this.cm;
    types = types || this.autopreviewTypes;

    // 不指定行，则一行一行的渲染全文
    if (lines == null) {
        cm.doc.eachLine( function (line) {
            cm.autopreview(line, types);
        });
    } else {
        //大部分情况下，也是为了效率，只渲染某些行
        if (typeof lines === "number") {
            lines = [lines];
        }
        var lastLine = cm.doc.lastLine();
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i];
            if (line > lastLine) continue;
            cm.autopreview(line, types);
        }
    }
},

addToAutopreviewQueue: function (lineNumber) {
    this.autopreviewQueue = this.autopreviewQueue || [];
    if (this.autopreviewQueue.indexOf(lineNumber) === -1) {
        this.autopreviewQueue.push(lineNumber);
    }
},

runAutopreviewQueue: function () {
    if (!this.autopreviewQueue) return;
    this.autopreview(null, this.autopreviewQueue);
    this.autopreviewQueue = [];
},

// -- 通过CodeMirror的事件来触发实时预览

// Listeners for cm events
that.cm.on("renderLine", function (cm, lineHandle, el) {
    // Line is not added to the DOM yet so use a queue which will be processed later
    var lineNumber = that.cm.doc.getLineNumber(lineHandle);
    that.addToAutopreviewQueue(lineNumber);
});

that.cm.on("beforeSelectionChange", function(cm, obj) {
    var ranges = cm.doc.listSelections();
    if (!ranges) return;
    ranges.forEach(function(range) {
        var firstLine = Math.min(range.anchor.line, range.head.line),
            lastLine = Math.max(range.anchor.line, range.head.line);
        for (var line = firstLine; line <= lastLine; line++) {
            that.addToAutopreviewQueue(line);
        }
    });
});

// 触发预览的核心，也就是在文档变化和光标变化时！
that.cm.on("cursorActivity", function (cm) {
    // Autopreview changed lines
    that.runAutopreviewQueue();
});

that.cm.on("changes", function (cm, changeObj) {
    // Window title update
    that.updateWindowTitle();
    // Autopreview changed lines
    that.runAutopreviewQueue();
});
```

autopreview可以指定渲染某些行，所以Abricotine在`renderLine`和`beforeSelectionChange`这两个事件发生时插入到需要渲染的行的队列，然后在`cursorActivity`和`changes`事件发生时进行渲染。

至于为什么添加和渲染要分开还不是太清楚。