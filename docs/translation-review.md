# 中文第二版校订说明

## 范围

本轮校订覆盖前言、主书第 1–19 章，以及仓库中随书发布的 Python Notebook 中文页面。参考文献题名、代码、变量名、数学公式和数据结果保持原文。

## 依据

- 官方英文仓库：`shokru/mlfactor.github.io`
- 对照提交：`572b22acd4dbf58ef9a6dadbdcd976344d3af1d4`
- 中文规范：[`translation-style-guide.md`](translation-style-guide.md)

## 方法

1. 逐页对齐中英文 HTML 正文块。
2. 逐段复核技术含义，并按中文语序重写直译句。
3. 统一金融、统计和机器学习术语。
4. 保留公式、代码、图表、文献引用和页面锚点。
5. 使用结构基线检查公式、代码、图像与链接数量。
6. 检查桌面和移动视口的目录、正文、公式、表格与代码块。

## 本地检查

校订完成后，35 个正式发布页面均通过自动审计。检查范围包括 HTML 语言标记、章节标题、禁用译法、强调标签间距、本地资源、公式、代码、图片、链接和页面锚点。

```bash
ruby scripts/apply_editorial_pass.rb
ruby scripts/audit_translation.rb
git diff --check
```

若本机已有官方英文仓库：

```bash
MLFACTOR_UPSTREAM=/path/to/mlfactor.github.io ruby scripts/audit_translation.rb
```

本轮对照官方英文提交执行上游审计时，全部检查通过。少数页面因中文版补充解释而比英文发布版多 1 个公式节点或正文块，审计将其列为提示，不视为内容损坏。

## 页面复核

- 桌面视口：1440 × 900。
- 移动视口：390 × 844。
- 抽查页面：首页、第 1、3、7、12、14 章及 Python Notebook 中文索引。
- 复核项目：页眉与目录、中文换行、数学公式、代码块、图片加载、长页面滚动及响应式布局。
