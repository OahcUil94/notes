---
typora-root-url: ../images
typora-copy-images-to: ../images/autohotkey
---



# windows下改键



鼠标右键, 新建`AutoHotkey Script`: 

![image-20201014150901461](/autohotkey/image-20201014150901461.png)

编辑脚本文件, 并写入如下内容(将`CapsLock键`改成`右Control`, 将`模拟鼠标右键菜单键`改成`左Win键`), 保存双击运行即可

```
$CapsLock::RControl
$AppsKey::LWin
```

