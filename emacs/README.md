# emacs

brew cask info emacs 

## Meta键

默认mac上的meta键是option或esc键

如何修改成command键盘：

```lisp
;;; I prefer cmd key for meta
(setq mac-option-key-is-meta nil
      mac-command-key-is-meta t
      mac-command-modifier 'meta
      mac-option-modifier 'none)
```

把上面的代码保存到~/.emacs.d/init.el文件中

## 如何新打开一个buffer

刚安装完软件, 然后进入的是一个只读的buffer, 有emacs相关的说明文档, 此时想要新开一个buffer, 可以按c-x b快捷键新打开一个buffer, c-x c-s来选择保存的路径

c-x 1只留一个窗口
