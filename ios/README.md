# 苹果常见问题

## 注册appleid的时候需要注意网络环境

注册appleid时, 需要注意网络环境, 网络环境决定了国籍, 不可使用vpn海外服务器加速, 否则国籍错误, 账号作废

## 提供新的邮件变更开发者持有人时, 手机双重认证不显示菜单, Mac系统无法开启双重认证

修改appleid国籍, 生日等基本信息, 确认修改完毕, 重新修改密码, 等待两步验证等候期结束(收到邮件), 再进行设置

```
xx，您好：
此电子邮件是为了通知您，您的等候期已结束。现在可以为您的 Apple ID (c•••••@zhixingglobal.com) 设置两步验证。
请前往 https://appleid.apple.com 登录您的 Apple ID 帐户页面，并在“安全”部分完成设置。更多信息，请参阅常见问题解答。
如果您未尝试设置两步验证，或认为有未经授权的人员访问了您的帐户，请前往您的 Apple ID 帐户页面 https://appleid.apple.com 并尽快更改您的密码。
为安全起见，此信息已自动发送至您帐户中登记的所有电子邮件地址。
如需其他帮助，请访问 Apple 支持。
此致
Apple 支持
```


## 切换appleid时提示, 若要将此Apple ID用作主要的iCloud账户, 请从“互联网账户”中删除它, 然后重新登录

1. 打开终端输入: `defaults delete MobileMeAccounts`

## 邓白氏编码查询

https://developer.apple.com/enroll/duns-lookup/

