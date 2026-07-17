# mlfactor-zh

《用于因子投资的机器学习》（*Machine Learning for Factor Investing*）中文静态电子书。

本仓库托管已生成的 bookdown HTML 文件，并通过 GitHub Pages 发布：

https://akirayu101.github.io/mlfactor-zh/

## 翻译维护

- 中文译名、术语和行文规范见 [`docs/translation-style-guide.md`](docs/translation-style-guide.md)。
- 批量高置信修订保存在 [`scripts/apply_editorial_pass.rb`](scripts/apply_editorial_pass.rb)，脚本可重复运行。
- 提交前运行 `ruby scripts/audit_translation.rb` 和 `git diff --check`，检查术语残留、本地资源以及公式、代码、图像和链接结构。
- 如已下载官方英文仓库，可运行 `MLFACTOR_UPSTREAM=/path/to/mlfactor.github.io ruby scripts/audit_translation.rb`，额外比较中英文发布版结构。
