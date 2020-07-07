# rust安装

1. 配置镜像地址

```bash
# 不建议使用清华开源镜像站
$ export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
$ export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
```

2. 下载并执行安装脚本

```bash
$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

安装过程中会出现以下类似提示, 选择1默认安装:

```
info: downloading installer

Welcome to Rust!

This will download and install the official compiler for the Rust
programming language, and its package manager, Cargo.

It will add the cargo, rustc, rustup and other commands to
Cargo's bin directory, located at:

  /Users/oahcuil/.cargo/bin

This can be modified with the CARGO_HOME environment variable.

Rustup metadata and toolchains will be installed into the Rustup
home directory, located at:

  /Users/oahcuil/.rustup

This can be modified with the RUSTUP_HOME environment variable.

This path will then be added to your PATH environment variable by
modifying the profile files located at:

  /Users/oahcuil/.profile
/Users/oahcuil/.zprofile

You can uninstall at any time with rustup self uninstall and
these changes will be reverted.

Current installation options:


   default host triple: x86_64-apple-darwin
     default toolchain: stable
               profile: default
  modify PATH variable: yes

1) Proceed with installation (default)
2) Customize installation
3) Cancel installation
```

安装完成后, 在`~/.cargo/bin`目录下可以找到安装的二进制文件.

3. 配置crates.io镜像源

编辑`~/.cargo/config`文件(这里只推荐配置阿里云的镜像源): 

```toml
[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"

replace-with = "rustcc"
[source.rustcc]
registry = "https://code.aliyun.com/rustcc/crates.io-index.git"
```

4. 永久配置镜像地址

```bash
$ echo "RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static" >> ~/.cargo/env
$ source ~/.cargo/env
```

## 参考资料

- [使用国内镜像加速 Rust 更新与下载](https://cloud.tencent.com/developer/article/1620144)