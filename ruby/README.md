# ruby

## ruby的安装

macOS安装命令: `brew install rbenv`, 安装完成后, 会添加两个命令行工具: `irb`和`ruby`

- `irb`可以直接在终端中输入ruby代码, 即时运行
- `ruby`用来运行`rb`代码文件



## helloworld

```ruby
puts "Hello World!"
```

执行: `ruby helloworld.rb`

## 数组类型

```ruby
arr = ["a", "b", "c"]
arr.each do |i|
    puts i
end
```

数组迭代: 

```ruby
arr = ["a", "b", "c"]
arr.each_index do |i|
    puts i
    puts arr.at(i)
end
```