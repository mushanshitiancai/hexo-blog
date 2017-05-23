---
title: Access批量导入Excel表格
date: 2017-05-23 13:45:09
categories:
tags:
---

考虑到明年可以不带钱去成都，我决定还是勉为其难研究一下怎么把Excel批量导入Access，毕竟以后要是开公司要上市了也需要这个步骤。

界面上，Access指让导入一个Excel，批量导入这种需求竟然在这么多版本后都没有加上也是汗颜。

手动导入一个的步骤：

![](/img/tools/access/import-1.png)

![](/img/tools/access/import-2.png)

然后下一步下一步就导入成功了。

批量导入的话，只能为VBA编程来实现。这个只能靠查资料了。

最终的代码：

```vb
Function Impo_allExcel()
    Dim myfile
    Dim mypath
    Dim myTableName
    
    mypath = "D:\我的文档\WeChat Files\mazhibin111\Files\"  '把这里换成你的保存excel文件的目录，注意最后有一个反斜杠
    myTableName = "NewTable" '把这里换成你在Access中想要新建的表格的名字

    myfile = Dir(mypath)
    Do While myfile <> ""
      If myfile Like "*.xlsx" Then
        DoCmd.TransferSpreadsheet acImport, 8, myTableName, mypath & myfile, True
      End If
      myfile = Dir()
    Loop
End Function
```

运行代码的方法：

![](/img/tools/access/run-code-1.png)

新建一个模块：

![](/img/tools/access/run-code-2.png)

把代码粘贴上去：

![](/img/tools/access/run-code-3.png)

把光标放在插入的代码中的任意位置，然后点击运行按钮：

![](/img/tools/access/run-code-4.png)

数据就导入成功了~

## 参考资料
- [How do I import multiple Excel files into Access at the same time??](https://social.msdn.microsoft.com/Forums/office/en-US/c2924fdf-448b-4b84-890c-907d5b653eeb/how-do-i-import-multiple-excel-files-into-access-at-the-same-time?forum=accessdev)
- [DoCmd.TransferSpreadsheet Method (Access)](https://msdn.microsoft.com/en-us/library/office/ff844793.aspx)