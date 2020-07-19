# golang内存分配

记录一些文章以及个人理解的内容

64位CPU, 地址总线64根, 一次可寻址64位, 8Byte地址

arena区域: 堆区, 512G, 按照8KB大小, 分成一个个page
spans区域: 存放span的指针, 每个指针对应一个page, 大小512GB/8KB*8B = 512M

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

## 参考资料

- [x] [简单易懂的 Go 内存分配原理解读](https://yq.aliyun.com/articles/652551)


