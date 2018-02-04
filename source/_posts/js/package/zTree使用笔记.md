---
title: zTree使用笔记
date: 2018-02-03 13:58:58
categories: [JavaScript]
tags: [javascript,js,jquery]
toc: true
---

zTree 是一个依靠 jQuery 实现的多功能 “树插件”。优异的性能、灵活的配置、多种功能的组合是 zTree 最大优点。

<!-- more -->

## 如何简单构建一个树？

```html
<html>
<head>
    <meta charset="UTF-8">
    <title>zTree Test</title>

    <!-- jQuery -->
    <script src="../bower_components/jquery/dist/jquery.js"></script>

    <!-- zTree -->
    <link rel="stylesheet" href="../bower_components/ztree/css/zTreeStyle/zTreeStyle.css" type="text/css">
    <script type="text/javascript" src="../bower_components/zTree/js/jquery.ztree.core.js"></script>
</head>
<body>
    <!-- 容器的id会被作为treeId -->
    <ul id="treeDemo" class="ztree"></ul>

    <script>
        var zTreeObj;
        // zTree 的参数配置
        var setting = {};
        // zTree 的初始节点数据
        var zNodes = [
            {
                name: "test1", open: true, children: [
                    { name: "test1_1" }, { name: "test1_2" }]
            },
            {
                name: "test2", open: true, children: [
                    { name: "test2_1" }, { name: "test2_2" }]
            }
        ];
        $(document).ready(function () {
            // 调用$.fn.zTree.init()方法构造树
            zTreeObj = $.fn.zTree.init($("#treeDemo"), setting, zNodes);
        });
    </script>
</body>
</html>
```

效果：

![](/img/ztree/first-demo.png)

## `$.fn.zTree.init()`是否可以多次调用？

可以。因为在init方法中会对容器做清理和事件解绑操作。

## 如何获得一个树的数据？

`zTreeObj.getNodes()`方法可以获取所有节点：

![](/img/ztree/get-nodes.png)

可以看出节点是对传入的节点数据做了拷贝和扩展的。

## 获取数据是否有开销？

```js
zTreeObj.getNodes: function (setting) {
    return data.nodeChildren(setting, data.getRoot(setting));
}
```

```js
// 从缓存中拿root节点
data.getRoot: function (setting) {
    return setting ? roots[setting.treeId] : null;
}

// 从节点中直接返回子节点数组
data.nodeChildren: function (setting, node, newChildren) {
    if (!node) {
        return null;
    }
    var key = setting.data.key.children;
    if (typeof newChildren !== 'undefined') {
        node[key] = newChildren;
    }
    return node[key];
}
```

从代码中可以可以看出，获取节点数据是直接返回内部维护的数据，所以基本无开销。

## “zTree内部的数据对象”是什么意思

在zTree的文档中，很多地方会看到“请务必保证此节点数据对象 是 zTree 内部的数据对象”这种描述，比如要更新一个节点，那么会要求指定的节点必须是内部数据对象。

这里的内部数据对象是什么意思呢？

因为zTree对于传入的节点数据都会复制一份，所以用于新建传入的节点数据是没什么用的，zTree内部不会保存引用，所以也就无法判断这个到底是哪个节点。

然后zTree内部维护了一个树对应的数据结构，是在传入的节点数据上做了扩展的对象。我们在getNodes系列函数中可以得到这些节点，然后就可以对这些节点进行操作。

所以文档要强调是“内部”数据结构。

这种设计是一种设计风格。另外的设计风格是在使用外部传入的对象，那么会带来很多的复杂性。因为外部对于对象的修改是不可控的，那么内部维持这个更新就非常麻烦了。

## 如何添加一个树节点？

`zTreeObj.addNodes(parentNode, [index], newNodes, isSilent)`

- `parentNode` 在哪个父节点下添加。如果要添加顶级节点，传null。
- `index` 添加的位置，0为第一个，-1为最后一个（可选）
- `newNodes` 新添加的节点数据，传入后会被拷贝
- `isSilent` 是否静默添加节点，如果为true，不会展开节点。默认为false（可选）

问题：这里的parentNode传入的不是zTree中维护的树节点会是什么效果？
TODO

## 如何更新一个树节点？

更新节点是一个比较泛的操作。

- 更新节点的名称
- 更新节点图标
- 关闭/打开节点
- 向节点插入/删除子元素

### 更新节点名称/图标等

`zTreeObj.updateNode(treeNode, checkTypeFlag)`

1. 可针对 name、target、 url、icon、 iconSkin、checked、nocheck 等这几个用于显示效果的参数进行更新，其他用于 zTreeNodes 的参数请不要随意更新，对于展开节点，还请调用 expandNode方法，因此请勿随意修改 open 属性。
2. 用此方法修改 checked 勾选状态不会触发 beforeCheck / onCheck 事件回调函数。

### 打开关闭节点

`zTreeObj.expandNode(treeNode, [expandFlag], [sonSign], [focus], [callbackFlag])`

- `treeNode` 需要打开关闭的节点
- `expandFlag` true展开节点，false折叠节点（可选，不传则根据当前状态）
- `sonSign` 是否对子孙节点进行expandFlag的操作（可选，默认false）
- `focus` 是否通过设置焦点保证此焦点进入可视区域内（可选，默认true）
- `callbackFlag` true 表示执行此方法时触发 beforeExpand / onExpand 或 beforeCollapse / onCollapse 事件回调函数（可选，默认false）
- 返回值：表示最终实际操作情况，true：展开，false：折叠，null：不是父节点

`zTreeObj.expandAll(expandFlag)`

此方法不会触发 beforeExpand / onExpand 和 beforeCollapse / onCollapse 事件回调函数。

### 向节点插入/删除子元素

添加/插入节点：`zTreeObj.addNodes(parentNode, [index], newNodes, isSilent)`

删除节点：`zTreeObj.removeNode(treeNode, callbackFlag)`

清空子节点：`zTreeObj.removeChildNodes(parentNode)`

## 如何获取选中的节点？

获取选中的节点：`zTreeObj.getSelectedNodes()`

- 如果没有选中节点，返回空数组。如果选中多个节点，按照选中的顺序返回。

选中节点：`zTreeObj.selectNode(treeNode, [addFlag], [isSilent])`

- `treeNode` 需要被选中的节点
- `addFlag` 是否添加选中到已有的选中数组中（可选，默认false）
- `isSilent` false表示会让选中的节点滚动到视野中（可选，默认false）

取消选中的节点：`zTreeObj.cancelSelectedNode(treeNode)`

- `treeNode` 如果省略此参数，则将取消全部被选中节点的选中状态。

## 树在DOM上是如何组织的？

![](/img/ztree/dom-struct.png)

根节点
1. dom元素是ul
2. id属性会被作为`treeId`，可以通过`setting.treeId`访问到
3. class属性用于样式，默认的样式表假设的class为`ztree`

子节点：
1. dom元素是li
2. 有三个子元素：折叠开关（span），图标和标题（a），子树（ul）

## 新建树的流程是如何的？

初始化zTree的方法：`$.fn.zTree.init(obj, zSetting, zNodes)`

参数说明：
- `obj` 树DOM容器，比如`$("#treeDemo")`
- `zSetting` zTree配置数据
- `zNodes` zTree节点数据，可以是Array/Object

返回值：zTree对象，对象上有setting对象和有操作树的方法。

init方法代码分析：

```js
init: function(obj, zSetting, zNodes) {
    // 复制默认配置并合并用户配置到默认配置
    var setting = tools.clone(_setting);
    $.extend(true, setting, zSetting);

    // DOM容器的id属性作为treeId
    setting.treeId = obj.attr("id");

    // 清空DOM容器
    setting.treeObj = obj;
    setting.treeObj.empty();

    // settings是zTree的全局缓存，保存所有实例的setting
    settings[setting.treeId] = setting;

    // 初始化root节点
    data.initRoot(setting);
    var root = data.getRoot(setting),

    // 复制外部传入的初始节点数据，并且规整为Array
    childKey = setting.data.key.children;
    zNodes = zNodes ? tools.clone(tools.isArray(zNodes)? zNodes : [zNodes]) : [];

    // 把子节点设置到root节点上
    if (setting.data.simpleData.enable) {
        root[childKey] = data.transformTozTreeFormat(setting, zNodes);
    } else {
        root[childKey] = zNodes;
    }

    data.initCache(setting);

    // 清空事件绑定，再进行事件绑定
    event.unbindTree(setting);
    event.bindTree(setting);

    // ？
    event.unbindEvent(setting);
    event.bindEvent(setting);

    // zTree实例对象，最后返回的对象
    var zTreeTools = {
        setting : setting,
        addNodes : function(parentNode, newNodes, isSilent) {
        // ...
        // 其他方法
    }
    root.treeTools = zTreeTools;
    data.setZTreeTools(setting, zTreeTools);

    // 新建子节点
    // 从这里可以看出，如果传入了初始节点数据，那么就无法使用async加载节点
    if (root[childKey] && root[childKey].length > 0) {
        view.createNodes(setting, 0, root[childKey]);
    } else if (setting.async.enable && setting.async.url && setting.async.url !== '') {
        view.asyncNode(setting);
    }
    return zTreeTools;
}
```

init中的逻辑只是新建了一个root节点，然后把传入的节点数据都放到这个root节点上。具体新建节点的逻辑在`view.createNodes()`这个内部方法中：

```js
view.createNodes: function (setting, level, nodes, parentNode, index) {
    if (!nodes || nodes.length == 0) return;
    var root = data.getRoot(setting),
        openFlag = !parentNode || parentNode.open || !!$$(data.nodeChildren(setting, parentNode)[0], setting).get(0);
    root.createdNodes = [];

    // 通过view.appendNodes()方法得到需要新建node的HTML字符串数组
    var zTreeHtml = view.appendNodes(setting, level, nodes, parentNode, index, true, openFlag),
        parentObj, nextObj;

    // parentObj赋值为ul元素
    if (!parentNode) {
        parentObj = setting.treeObj;
    } else {
        var ulObj = $$(parentNode, consts.id.UL, setting);
        if (ulObj.get(0)) {
            parentObj = ulObj;
        }
    }
    if (parentObj) {
        if (index >= 0) {
            nextObj = parentObj.children()[index];
        }
        if (index >= 0 && nextObj) {
            // 把节点HTML插入到ul容器中index指定的位置
            $(nextObj).before(zTreeHtml.join(''));
        } else {
            // 把节点HTML追加到ul容器
            parentObj.append(zTreeHtml.join(''));
        }
    }

    view.createNodeCallback(setting);
}
```

可以看出关键代码在`view.appendNodes()`方法中，这个方法返回了节点的HTML：

```js
view.appendNodes: function (setting, level, nodes, parentNode, index, initFlag, openFlag) {
    if (!nodes) return [];
    var html = [];

    var tmpPNode = (parentNode) ? parentNode : data.getRoot(setting),
        tmpPChild = data.nodeChildren(setting, tmpPNode),
        isFirstNode, isLastNode;

    if (!tmpPChild || index >= tmpPChild.length - nodes.length) {
        index = -1;
    }

    for (var i = 0, l = nodes.length; i < l; i++) {
        var node = nodes[i];
        if (initFlag) {
            isFirstNode = ((index === 0 || tmpPChild.length == nodes.length) && (i == 0));
            isLastNode = (index < 0 && i == (nodes.length - 1));
            data.initNode(setting, level, node, parentNode, isFirstNode, isLastNode, openFlag);
            data.addNodeCache(setting, node);
        }
        var isParent = data.nodeIsParent(setting, node);

        // 如果新建的节点有子节点，则递归获取子节点HTML
        var childHtml = [];
        var children = data.nodeChildren(setting, node);
        if (children && children.length > 0) {
            //make child html first, because checkType
            childHtml = view.appendNodes(setting, level + 1, children, node, -1, initFlag, openFlag && node.open);
        }

        // 如果新建的节点所在的父节点是打开的，则需要渲染HTML
        if (openFlag) {
            view.makeDOMNodeMainBefore(html, setting, node);
            view.makeDOMNodeLine(html, setting, node);
            data.getBeforeA(setting, node, html);
            view.makeDOMNodeNameBefore(html, setting, node);
            data.getInnerBeforeA(setting, node, html);
            view.makeDOMNodeIcon(html, setting, node);
            data.getInnerAfterA(setting, node, html);
            view.makeDOMNodeNameAfter(html, setting, node);
            data.getAfterA(setting, node, html);
            if (isParent && node.open) {
                view.makeUlHtml(setting, node, html, childHtml.join(''));
            }
            view.makeDOMNodeMainAfter(html, setting, node);
            data.addCreatedNode(setting, node);
        }
    }
    return html;
}
```

zTree的新建View的模式是，一行一行的拼接HTML，然后放到数组中，等于是通过数组来解耦。。

好坏暂时无法评论。

## 传入的初始设置和数据，zTree是否会持有引用？

根据上文分析`$.fn.zTree.init()`，传入的设置和节点数据，zTree都会复制一份。

所以传入后修改这些对象是无意义的。也没必要继续持有这些对象的引用。


## 参考资料
- [API 文档 [zTree -- jQuery 树插件]](http://www.treejs.cn/v3/api.php)

