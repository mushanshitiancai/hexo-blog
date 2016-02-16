---
title: php中array与xml互转
date: 2016-02-16 14:56:24
tags: [php]
---

查了很多资料，PHP中array和xml互转的做法都非常“野”。。。。

## xml字符串转array

    $array=json_decode(json_encode(@simplexml_load_string($xmlstring)),true);

`simplexml_load_string`返回的是对象，然后通过json为中介，转换成数组。

## array转换成xml字符串

```
function array_to_xml($data, $root = "root"){
    $xml_data = new SimpleXMLElement("<?xml version=\"1.0\"?><$root></$root>");
    foreach ($data as $key => $value) {
        if (is_numeric($key)) {
            $key = 'item' . $key;
        }
        if (is_array($value)) {
            $subnode = $xml_data->addChild($key);
            array_to_xml($value, $subnode);
        } else {
            $xml_data->addChild("$key", htmlspecialchars("$value"));
        }
    }
    return $xml_data->asXML();
}
```

这个代码是我修改stackoverflow的回答得到的。回答的代码里有一个bug：`array(0,1)`会生成`<0>0</0><1>1</1>`。而xml的标签是不允许数字开头的（只能字母或下划线开头）。


## 参考地址
- [Convert array to XML in PHP - CodexWorld](http://www.codexworld.com/convert-array-to-xml-in-php/)
- [How to convert xml into array in php? - Stack Overflow](http://stackoverflow.com/questions/6578832/how-to-convert-xml-into-array-in-php)
- [php - How to convert array to SimpleXML - Stack Overflow](http://stackoverflow.com/questions/1397036/how-to-convert-array-to-simplexml)
