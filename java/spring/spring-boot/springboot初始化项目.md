---
typora-root-url: ../../../images
typora-copy-images-to: ../../../images
---

# SpringBoot初始化项目

[TOC]

## 使用IDEA快速创建一个SpringBoot项目

### 基本流程

New Project -> Spring Initializr: 

<img src="/image-20201001203542071.png" alt="image-20201001203542071" style="zoom:50%;" />

填写项目信息: 

<img src="/image-20201001203824775.png" alt="image-20201001203824775" style="zoom:50%;" />

选择Web->Spring Web:

<img src="/image-20201001203914861.png" alt="image-20201001203914861" style="zoom:50%;" />

查看一下Project name和Project location, 点击Finish按钮: 

<img src="/image-20201001204111427.png" alt="image-20201001204111427" style="zoom:50%;" />

进入项目界面, 此时会发现一直会卡在`Reading /path/pom.xml...`这里, 原因是IDEA已经支持了`Maven Wrapper`: 

<img src="/image-20201001213858972.png" alt="image-20201001213858972" style="zoom:50%;" />



### Maven Wrapper(Reading pom.xml...卡顿原因)

#### 下载Maven

由于IDEA支持了`Maven Wrapper`, 可查看`maven-wrapper.properties`文件的内容: 

```properties
distributionUrl=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.6.3/apache-maven-3.6.3-bin.zip
wrapperUrl=https://repo.maven.apache.org/maven2/io/takari/maven-wrapper/0.5.6/maven-wrapper-0.5.6.jar
```



刚初始化完项目, IDEA会自动下载上面的两个地址, 由于国内的网络情况, 下载速度异常缓慢, 就会导致IDEA出现卡顿问题, 解决方案是可将`https://repo.maven.apache.org/maven2/`替换成阿里云的`https://maven.aliyun.com/repository/central`, 修改`maven-wrapper.properties`文件的内容:

```properties
distributionUrl=https://maven.aliyun.com/repository/central/org/apache/maven/apache-maven/3.6.3/apache-maven-3.6.3-bin.zip
wrapperUrl=https://maven.aliyun.com/repository/central/io/takari/maven-wrapper/0.5.6/maven-wrapper-0.5.6.jar
```

命令行执行 `./mvnw -v`, 虽然该命令看似是在查看版本信息, 但是脚本会检查`~/.m2/wrapper`目录下是否有`maven-wrapper.properties`文件中指定的`maven`版本, 如果没有, 则会进行下载: 

```
.
└── wrapper
    └── dists
        └── apache-maven-3.6.3-bin
            └── 4n30rkinm9sb4k1d54frdvf3ga
                ├── apache-maven-3.6.3
                │   ├── LICENSE
                │   ├── NOTICE
                │   ├── README.txt
                │   ├── bin
                │   ├── boot
                │   ├── conf
                │   └── lib
                └── apache-maven-3.6.3-bin.zip
```



> 不要使用`./mvnw clean`, 该命令会下载`maven`并会从maven官方仓库下载依赖包, 很慢



#### 下载依赖包

下载了`maven`之后, 打开IDEA, 会自动下载包, 此时IDEA的下载行为会读取IDEA构建工具Maven中配置的settings.xml文件, 例如包含了阿里云镜像源，进行下载: 



<img src="/image-20201001222645982.png" alt="image-20201001222645982" style="zoom:50%;" />

