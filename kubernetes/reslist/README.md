kubectl get pod xxx -o yaml


apiVersion: 声明k8s对象所属的api版本或者api组, group/version, 省略group/,  表示核心组
kind: 资源类别Pod
metadata: 元数据
spec: specification规格, 定义k8s对象应该所处的目标状态, 期望状态
  tolerations: 容忍度
status: 当前目标的当前状态(只读)

k8s就是用于确保定义的每个资源, 当前状态无限向目标状态靠近或转移, 从而满足用户期望

创建资源的方法: 

apiserver仅接收JSON格式的资源定义: kubectl run会自动把给定的命令转成json格式而已

大部分资源的配置清单: 大多数都由5个组成: 

1. apiVersion: kubectl api-versions
2. kind: 资源类别
3. metadata: 元数据
    name: 在同一类别当中, name必须是唯一的
    namespace: 命名空间, 不同的命名空间, name可以重名
    labels: 标签, 用于标签选择器
    annotations: 资源注解


每个资源的引用路径: /api/GROUP/VERSION/namespaces/NAMESPACENAME/TYPE/NAME

spec: 期望状态: disired state

查看pod可以定义哪些字段
kubectl explain pods.metadata

apiVersion: v1

kubectl logs pod-demo myapp

自主式pod资源
