# mlfactor-zh

《用于因子投资的机器学习》（*Machine Learning for Factor Investing*）中文静态电子书。

本仓库托管已生成的 bookdown HTML 文件，并通过 GitHub Pages 发布：

https://akirayu101.github.io/mlfactor-zh/

## PWA 与本地预览

网站支持安装到手机桌面，并会预缓存中文版正文以供离线阅读。图片和其他资源会在首次阅读时自动缓存。页面支持明暗主题切换，首次访问跟随系统设置，手动选择后会在本机保存。

- iPhone / iPad：使用 Safari 打开网站，点击页面右下角的“添加到主屏幕”，再按提示从分享菜单选择“添加到主屏幕”。iOS 不提供网页内的自动安装弹窗。
- Android / 桌面浏览器：点击浏览器提供的安装提示，或使用页面右下角的“安装到手机”。

Service Worker 需要通过 HTTP(S) 访问，本地预览可运行：

```sh
python -m http.server 8000 --bind 127.0.0.1
```

然后打开 http://127.0.0.1:8000/。生成 PWA 图标和重新为 HTML 页面注入公共资源时，分别运行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/generate_pwa_icons.ps1
powershell -ExecutionPolicy Bypass -File scripts/inject_pwa.ps1
```

## 翻译维护

- 中文译名、术语和行文规范见 [`docs/translation-style-guide.md`](docs/translation-style-guide.md)。
- 批量高置信修订保存在 [`scripts/apply_editorial_pass.rb`](scripts/apply_editorial_pass.rb)，脚本可重复运行。
- 提交前运行 `ruby scripts/audit_translation.rb` 和 `git diff --check`，检查术语残留、本地资源以及公式、代码、图像和链接结构。
- 如已下载官方英文仓库，可运行 `MLFACTOR_UPSTREAM=/path/to/mlfactor.github.io ruby scripts/audit_translation.rb`，额外比较中英文发布版结构。
