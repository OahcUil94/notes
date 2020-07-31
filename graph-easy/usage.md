# graph easy用法

gitbook: [https://weishu.gitbooks.io/graph-easy-cn/content/index.html](https://weishu.gitbooks.io/graph-easy-cn/content/index.html)

## 单节点

```
$ graph-easy <<< '[a]'

+---+
| a |
+---+
```

## 复合节点

```
$ graph-easy <<< '[a | b | c | d]'

+---+---+---+---+
| a | b | c | d |
+---+---+---+---+
```

## 文件里面文档注释

```
# top
[a] <=> [b] # mid
# test
```

## 连接线注释

```
$ graph-easy <<< '[a] -- {label: "this is test line"} [b]'

+---+  this is test line   +---+
| a | -------------------- | b |
+---+                      +---+
```

## 不同边线

```
[ Bonn ] <-> [ Berlin ]         # bidirectional
[ Berlin ] ==> [ Rostock ]      # double
[ Hamburg ] ..> [ Altona ]      # dotted
[ Dresden ] - > [ Bautzen ]     # dashed
[ Leipzig ] ~~> [ Kirchhain ]   # wave
[ Hof ] .-> [ Chemnitz ]        # dot-dash
[ Magdeburg ] <=> [ Ulm ]       # bidrectional, double etc
[ Magdeburg ] -- [ Ulm ]        # arrow-less edge
```

## 节点组

```
$ graph-easy <<< "(UI layer: [a],[b],[c])"

+ - - - - - - +
' UI layer:   '
'             '
' +---------+ '
' |    a    | '
' +---------+ '
' +---------+ '
' |    b    | '
' +---------+ '
' +---------+ '
' |    c    | '
' +---------+ '
'             '
+ - - - - - - +

$ graph-easy <<< "(backend: [a]->[b]) [b]->[c]"

+ - - - - - - - - - - -+
' backend:             '
'                      '
' +--------+     +---+ '     +---+
' |   a    | --> | b | ' --> | c |
' +--------+     +---+ '     +---+
'                      '
+ - - - - - - - - - - -+
```

## 设置边的流向

方法是{flow:south}, 方向可以是north/south/east/west(北/南/东/西), 也可以是left/right/up/down（左/右/上/下）
代码: [a]{flow:south}->[b]->[c]

```
$ graph-easy <<< '[a]{flow:south}->[b]->[c]'

+---+
| a |
+---+
  |
  |
  v
+---+     +---+
| b | --> | c |
+---+     +---+
```

## 设置高度

```
$ graph-easy <<< '[a]{rows:3}->[b]->[c]->[a]'

+---+     +---+     +---+
|   | --> | b | --> | c |
| a |     +---+     +---+
|   |                 |
|   | <---------------+
+---+
```

## 设置边框样式

```
$ graph-easy <<< '[a]{border:1px dotted black}->[b]{border:none}->[c]{border:1px solid gray}'

.....             +---+
: a : -->  b  --> | c |
:...:             +---+
```

## 综合案例

### VOD简单概念组合

```
# Template group
[Template group] -> [name]
[Template group] -> {label: "Single Template"} [Template]
# Template
[Template] -> [video]
[Template] -> [audio]
[Template] -> [watermark]
# video
[video] -> [definition]
[video] -> [bitRate]
[video] -> [encode]

# 输出

                                      +-----------+     +------------+
                                      | watermark |     |   encode   |
                                      +-----------+     +------------+
                                        ^                 ^
                                        |                 |
                                        |                 |
+----------------+  Single Template   +-----------+     +------------+     +---------+
| Template group | -----------------> | Template  | --> |   video    | --> | bitRate |
+----------------+                    +-----------+     +------------+     +---------+
  |                                     |                 |
  |                                     |                 |
  v                                     v                 v
+----------------+                    +-----------+     +------------+
|      name      |                    |   audio   |     | definition |
+----------------+                    +-----------+     +------------+
```

### OAuth2.0的授权认证流程图

```
[ Client ]{rows:8;} -- (A) Authorizatoin Request --> [ 1.Resource Owner ]{rows:2;}
[ 1.Resource Owner ] -- (B) Authorizatoin Grant --> [ Client ]
[ Client ] -- (C) Authorizatoin Request --> [ 2.Authorizatoin Server ]{rows:2;}
[ 2.Authorizatoin Server ] -- (D) Access Token --> [ Client ]
[ Client ] -- (E) Access Token --> [ 3.Resource Server ]{rows:2;}
[ 3.Resource Server ] -- (F) Protected Resource --> [ Client ]

# 输出
+--------+  (A) Authorizatoin Request   +------------------------+
|        | ---------------------------> |                        |
|        |                              |    1.Resource Owner    |
|        |  (B) Authorizatoin Grant     |                        |
|        | <--------------------------- |                        |
|        |                              +------------------------+
|        |  (C) Authorizatoin Request   +------------------------+
|        | ---------------------------> |                        |
| Client |                              | 2.Authorizatoin Server |
|        |  (D) Access Token            |                        |
|        | <--------------------------- |                        |
|        |                              +------------------------+
|        |  (E) Access Token            +------------------------+
|        | ---------------------------> |                        |
|        |                              |   3.Resource Server    |
|        |  (F) Protected Resource      |                        |
|        | <--------------------------- |                        |
+--------+                              +------------------------+
```
