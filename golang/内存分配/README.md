# golang内存分配

记录一些文章以及个人理解的内容

64位CPU, 地址总线64根, 一次可寻址64位, 8Byte地址

arena区域: 堆区, 512G, 按照8KB大小, 分成一个个page
spans区域: 存放span的指针, 每个指针对应一个page, 大小(512GB/8KB计算出多少页)*8B = 512M
spans区域: 存放mspan指针, 表示arena区中的某一页属于哪个mspan, page与mspan的对应
bitmap区域: 位图, 一个功能一个bit, 两个功能, 功能一标记对应地址中是否存在对象, 功能二标记对象是否被gc标记过 16GB

512G的内存大小, 按照8KB一页划分, 一共是65536页, 也就是65536个地址, 一个地址对应两个功能, 也就是2bit, (65536 * 2 bit) / 8 / 1024 = 16GBS

一个span可以包含1~n个page, 然后对span进行更细粒度的划分, 按照设定好的object尺寸进行划分

span就是mspan, m表示结构体的意思

//    10        144        8192       56          128

cache管理着span

一个链表 有多个span 一个span有多个page

1 linklist -> N span -> M page
1 linklist -> N span -> M 块(按照对象大小划分)

每个mcentral对应一种span class

mheap结构对应着三种内存结构spans, bitmap, arena

源码: runtime/mheap.go

go将内存块分为大小不同的67种, 再把67种大内存块, 逐个分为小块, 不理解, 67种内存块, 第二种, 对应的内存块就是8B-8192B规格, 是只有一块这种规格的内存块, 还是很多, 还分为小块, 小块叫span? 

## 参考资料

- [x] [简单易懂的 Go 内存分配原理解读](https://yq.aliyun.com/articles/652551)
- [ ] [图解Golang的内存分配 ](https://i6448038.github.io/2019/05/18/golang-mem/) 看到一半