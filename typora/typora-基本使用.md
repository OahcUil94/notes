---
title: Typora基本使用
date: 2020-10-13 18:14
categories: 
	- typora
	- usage
tags: [typora, markdown]
typora-root-url: ../
typora-copy-images-to: ../images/typora
---

# Typora 基本使用

[TOC]

## front matter

`front matter`可以针对每篇文章进行一些配置, 支持yaml格式, 可以进行的配置项有: 

- `title`: 文章标题
- `date`: 文章创建时间, 时间格式`YYYY-MM-DD HH:MM:SS +/-TTTT`
- `author`: 文章作者
- `categories/category`: 文章分类, 有顺序和层级关系
- `tags:` 文章标签
- `typora-root-url`: 文章引入本地静态资源时, 相对于该目录生成路径, 可设置相对路径和绝对路径, 例如: `typora-root-url: ../`
- `typora-copy-images-to`: 复制本地图片到文章中时, 默认保存到哪个目录下(相对于`typora-root-url`设置的目录), 例如: `typora-copy-images-to: ../images/typora`

![image-20201013181603245](/images/typora/image-20201013181603245.png)

