# iTerm2配置

## 安装Dracula主题

下载主题`git clone https://github.com/dracula/iterm.git`, 在iTerms中进行设置`iTerm2 > Preferences > Profile > Colors > Color Presets > Import`

[https://draculatheme.com/iterm](https://draculatheme.com/iterm)

## 备选主题material design

[https://github.com/MartinSeeler/iterm2-material-design](https://github.com/MartinSeeler/iterm2-material-design)

## 配置FiraCode字体

- 设置: `iTerm2 > Preferences > Profile > Text > Font > Fira Code, Regular, 14`
- 勾选复选框: `Use ligatures`, `Anti-aliased`

## zsh

查看更多主题: [https://github.com/ohmyzsh/ohmyzsh/wiki/Themes](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)

### 安装powerline-fonts

[https://github.com/powerline/fonts](https://github.com/powerline/fonts)

### 切换agnoster主题

[https://github.com/agnoster/agnoster-zsh-theme](https://github.com/agnoster/agnoster-zsh-theme)

zsh已经安装了大部分常用的主题, 可在`~/.oh-my-zsh/themes`目录下找到, 编辑`.zshrc`文件, 修改`ZSH_THEME="agnoster"`配置项, 执行`source ~/.zshrc`即可

> 注意: 路径前缀的XX@XX太长, 找到agnoster.zsh-theme文件, 将文本文件里面的build_prompt下的prompt_context字段在前面加#注释掉即可

### 安装powerlevel9k主题

[https://github.com/Powerlevel9k/powerlevel9k](https://github.com/Powerlevel9k/powerlevel9k)

该主题和`agnoster`主题样式类似, 但是可配置项更多:

- 下载主题: `git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k`
- 配置主题: `ZSH_THEME="powerlevel9k/powerlevel9k"`

定制提示符, 直接在`.zshrc`文件里增加环境变量即可: 

```zsh
# 注意：DEFAULT_USER 的值必须要是系统用户名才能生效(如何系统用户名和home目录的文件夹名字不一致, 也填写系统用户名)
DEFAULT_USER="xxxx"

# 设置 oh-my-zsh powerlevel9k 主题左边元素显示
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(user dir dir_writable vcs)
# 设置 oh-my-zsh powerlevel9k 主题右边元素显示
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status go_version)
```

### 安装语法高亮插件

[https://github.com/zsh-users/zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)

`git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting`

`zsh`能够很好的提供`git`相关命令的高亮, 原因就是`zsh`默认安装了`git`的插件, 将安装好的插件配置在`plugins`项中即可: 

```zsh
plugins=(
    git
    zsh-syntax-highlighting
)
```

### 安装自动补全插件

[https://github.com/zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)

`git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions`

```zsh
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
)
```

## 参考文章

- [https://blog.csdn.net/dianfu2892/article/details/101467017](https://blog.csdn.net/dianfu2892/article/details/101467017)

https://github.com/ryanoasis/nerd-fonts

