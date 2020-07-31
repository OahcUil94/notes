# Graph Easy

画ASCII流程图工具, 可以使用中文

github地址: [Graph-Easy](https://github.com/ironcamel/Graph-Easy)

## 安装

1. `brew install graphviz`
2. 检查`cpan`, 执行`cpan`
3. `sudo cpan Graph:Easy`

## 配置环境变量

```bash
GRAPH_EASY=/Users/***/.cpan/build/Graph-Easy-0.76-1_zAcK/blib/script
PATH=$GRAPH_EASY:$PATH:.
export PATH
```

## 中文格式问题解决

### 修改文件内容

下面的`a`, `b`目录代表的就是`/Users/***/.cpan/build/Graph-Easy-0.76-1_zAcK/`: 

```
diff --git a/lib/Graph/Easy.pm b/lib/Graph/Easy.pm
index 0ae40fd..b67bacc 100644
--- a/lib/Graph/Easy.pm
+++ b/lib/Graph/Easy.pm
@@ -1570,7 +1570,9 @@ sub as_ascii
   # select 'ascii' characters
   $self->{_ascii_style} = 0;

-  $self->_as_ascii(@_);
+  my $asc = $self->_as_ascii(@_);
+  $asc =~ s/(\x{FFFF})//g;
+  $asc;
   }

 sub _as_ascii
diff --git a/lib/Graph/Easy/Node.pm b/lib/Graph/Easy/Node.pm
index b58f538..6d7d7c7 100644
--- a/lib/Graph/Easy/Node.pm
+++ b/lib/Graph/Easy/Node.pm
@@ -1503,6 +1503,9 @@ sub label

   $label = $self->_un_escape($label) if !$_[0] && $label =~ /\\[EGHNT]/;

+  # placeholder for han chars
+  $label =~ s/([\x{4E00}-\x{9FFF}])/$1\x{FFFF}/g;
+
   $label;
   }
```

> 注意: `Easy.pm`和`Easy/Node.pm`两个文件都是只读的, 尝试创建超级管理员账户, `sudo passwd root`, 切换超级管理员账户`sudo su`, 然后继续修改两个文件, 发现还是只读的, 此时可以直接通过图形界面找到这两个问题, 然后右键菜单`显示简介`, 最下面`共享与权限`里面的`只读`权限改成`读写`

### 编译安装

1. `cd build/Graph-Easy-0.76-1_zAcK`
2. 运行`perl Makefile.PL`来创建`make`文件, 同时执行`make test`来运行测试套件
3. 如果所有的测试都PASS通过了，以管理员权限执行编译: `sudo make install`

## 相关示例

1. 分支: graph-easy <<< '[a]->[b]->[c][b]->[d]->[e]'
2. 闭环: graph-easy <<< '[a]->[b]->[c]->[b]->[d]->[e]'
3. 合流: graph-easy <<< '[a]->[b]->[c][d]->[e]->[b]'
4. 流程说明: graph-easy <<< '[a]- say hello ->[b]'
5. 上下结构: graph-easy <<< 'graph{flow:south;}[上]->[中]->[下]'

读取文本文件的内容, 执行`graph-easy graph-easy.text`

graph-easy.txt文件: 

```
[Instapaper] {size: 2,7;}
[RSS(Feedly)] -> [Instapaper]{ origin: RSS(Feedly); offset: 2,0;}
[WeChat] -> [Instapaper]{ origin: WeChat; offset: 2,-6;}
[Website] -> [Instapaper]
[IFTTT]{size: 1,7;}
[Instapaper] -> [Diigo]{ origin: Instapaper; offset: 2,-2;}
[Instapaper] -> [IFTTT]{ origin: Instapaper; offset: 2,0;}
[Instapaper] -> [Evernote]{ origin: Instapaper; offset: 2,2;}
[Webtask(Serverless)]{size: 2,7;}
[IFTTT] -> [Webtask(Serverless)]{ origin: IFTTT; offset: 2,0;}
```

## 边的风格

```
->              实线
=>              双实线
.>              点线
~>              波浪线
- >             虚线
.->             点虚线
..->            dot-dot-dash
= >             double-dash
```

## 参考资料

- [Mac使用Graph Easy（纯文本流程图）](https://www.jianshu.com/p/6528d4b63b87)
