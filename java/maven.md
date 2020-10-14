# maven

jar包管理器

## 下载

maven下载地址: [http://maven.apache.org/download.cgi](http://maven.apache.org/download.cgi)

## 配置环境变量

编辑`.zshrc`文件: 

```bash
# 注意: 这里不能用~表示当前用户目录
export M2_HOME=/Users/xxx/software/apache-maven-3.6.3
export PATH=$PATH:$M2_HOME/bin
```

重启终端或执行`source ~/.zshrc`

关于环境变量, 如果maven版本超过了`3.5`, 不配置环境变量, 直接在IDE中配置: 

`https://stackoverflow.com/questions/17136324/what-is-the-difference-between-m2-home-and-maven-home`

MAVEN_HOME适用于Maven1, M2_HOME适用于Maven2及更高版本
Maven2是对Maven1的完全重写, 并且不向后兼容. 具有两个不同的_HOME变量意味着可以在同一台计算机上同时运行这两个变量.
从maven 3.5.0开始, 这些环境变量都不应该指定. 相反, 应该更新路径以包含mvn可执行文件.

## 验证安装成功

`mvn -v`

## 修改相关配置

修改`conf/settings.xml`文件, 编辑以下内容: 

```xml
<!-- 从远程仓库下载的jar包存放的位置 -->
<localRepository>/Users/oahcuil/software/apache-maven-3.6.3/repo</localRepository>

<!-- 配置阿里云的镜像仓库 -->
<mirrors>
  <mirror>
    <id>alimaven</id>
    <name>aliyun maven</name>
    <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
    <mirrorOf>central</mirrorOf>
  </mirror>
 </mirrors>
```

## Intellij IDEA配置

Preferences -> Build, Execution, Deployment -> Build Tools -> Maven, 配置下面三项: 

1. Maven home directory
2. User settings file
3. Local repository

## Intellij IDEA创建Maven项目

GroupId: 公司或者组织域名的倒写
ArtifactId: 通常指项目名称
Name: 项目名

项目自动生成以下文件结构:

```
.
├── pom.xml 项目依赖配置
├── spring_study.iml
└── src
    ├── main
    │   ├── java 存放核心java代码
    │   └── resources 添加配置文件
    └── test
        └── java 存放测试代码
```

## 搜索需要引入的jar包

打开[https://mvnrepository.com/](https://mvnrepository.com/)用来搜索一些jar包

找到需要依赖的jar包之后, 点击对应的版本, 将其中的xml代码粘贴到`pom.xml`的`dependencies`标签中, 例如引入spring-context依赖:

```
<dependencies>
    <!-- https://mvnrepository.com/artifact/org.springframework/spring-context -->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-context</artifactId>
        <version>5.2.9.RELEASE</version>
    </dependency>
</dependencies>
```

然后根据IDEA的配置去自动下载导入spring-context依赖
