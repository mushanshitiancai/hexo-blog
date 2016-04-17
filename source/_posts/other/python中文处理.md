---
title: python中文处理
date: 2016-02-01 10:45:59
tags: [python]
---

python的中文处理真的很烦。别的语言在发展过程中，能够在向前兼容的情况下做到支持utf-8，Python你就不能？

## 写入文件时遇到错误

    UnicodeEncodeError: 'ascii' codec can't encode character u'\u5e74' in position 4: ordinal not in range(128)

解决：

```
import sys  
reload(sys)  
sys.setdefaultencoding('utf-8')
```

[Python编码错误处理 - xiaokang06的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/xiaokang06/article/details/8229061)
