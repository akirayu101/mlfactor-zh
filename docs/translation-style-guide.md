# 《用于因子投资的机器学习》中文翻译规范

本规范用于第二版中文书稿的统一校订。翻译以英文原版为依据，优先保证技术含义准确，其次保证中文自然、简洁；不得为了“顺口”改动公式、代码、变量名、数据事实或作者观点。

## 基本原则

1. **信**：先确认主语、逻辑关系、时间方向和统计含义，再组织中文。不得根据现有中文猜测原意。
2. **达**：按中文语序重写，避免逐词对应。长句可拆分，但不得丢失限定条件和转折关系。
3. **雅**：采用现代技术写作风格，避免翻译腔、口号式表达和不必要的书面套话。
4. **一致**：同一概念在全书使用同一主译名；必要时在首次出现处保留英文或缩写。
5. **可读**：面向具备基础金融和机器学习知识的读者。概念名称准确，解释尽量直白。

## 术语表

| English | 统一译法 | 说明 |
|---|---|---|
| Machine Learning for Factor Investing | 用于因子投资的机器学习 | 书名 |
| notation | 符号约定 / 记号 | 章节标题用“符号约定” |
| instance / observation | 样本 / 观测 | 不译为“实例” |
| feature / predictor | 特征 / 预测变量 | predictor 不译为“预测器” |
| label / target | 标签 / 目标变量 | 依上下文选用 |
| response / dependent variable | 响应变量 / 因变量 | |
| cross-section | 横截面 | |
| panel data | 面板数据 | |
| expected return | 预期收益率 | 与 realized return 区分 |
| realized return | 已实现收益率 | |
| forward return | 未来收益率 | 不用“远期收益率”，除非涉及远期合约 |
| risk premium | 风险溢价 | |
| asset-pricing anomaly | 资产定价异象 | 首次出现可解释为“经验规律” |
| portfolio sort | 投资组合排序法 | 必要时解释为“按特征分组” |
| long-short portfolio | 多空投资组合 | |
| short selling / short leg | 卖空 / 空头端 | 不用“买空” |
| regularization | 正则化 | |
| penalization | 惩罚 / 惩罚项 | |
| shrinkage | 收缩 | |
| estimator / estimate | 估计量 / 估计值 | 严格区分 |
| inference | 推断 | 不译为“推理” |
| out-of-sample / in-sample | 样本外 / 样本内 | |
| validation set | 验证集 | 与测试集区分 |
| hyperparameter tuning | 超参数调优 | 不用“调参”作标题 |
| ensemble | 集成 / 集成学习 | |
| learner / weak learner | 学习器 / 弱学习器 | |
| tree-based methods | 树模型 / 基于树的方法 | |
| margin (SVM) | 间隔 | 不译为“保证金” |
| slack variable | 松弛变量 | |
| data snooping | 数据窥探 | |
| p-hacking | p 值操纵 | |
| look-ahead bias | 前视偏差 | |
| survivorship bias | 幸存者偏差 | |
| overfitting | 过拟合 | 不用“过度拟合” |
| turnover | 换手率 | |
| transaction cost | 交易成本 | |
| benchmark | 基准 | |
| drawdown / maximum drawdown | 回撤 / 最大回撤 | |
| interpretability | 模型可解释性 | |
| causality | 因果关系 | “因果性”仅在强调性质时使用 |
| non-stationarity | 非平稳性 | |
| covariate shift | 协变量偏移 | |
| concept drift | 概念漂移 | |
| regret (online learning) | 遗憾值 | |
| no-free-lunch theorem | 没有免费午餐定理 | |
| pipeline / pipe operator | 工作流 / 管道操作符 | 依上下文区分 |
| package | 软件包 | 包名、函数名和变量名保持原文 |

## 表达与格式

- 中文正文使用全角标点；公式、代码、URL、软件包名和文献题名保持原样。
- 中文与行内公式、英文缩写、数字之间保留一个半角空格；中文标点前不留空格。
- 首次出现可写作“支持向量机（support vector machine，SVM）”，后文统一使用“SVM”。
- `R`、`Python`、`tidyverse`、`dplyr`、`XGBoost` 等名称不得翻译。
- `beta` 作为金融概念译为“贝塔”；作为统计系数且公式已给出时可写“系数 $\beta$”。
- 图表标题用名词短语，正文引用统一写作“图 3.1”“表 4.2”“第 5.3 节”。
- 避免“进行一个……”“从……方面”“就……而言”“后者”“显然”等直译套语；能直接陈述就直接陈述。
- 不擅自强化结论。原文的 `may`、`can`、`likely`、`suggest` 等不确定性必须保留。

## 校订验收

- 每章逐段与官方英文页面对照。
- 数学公式、代码块、链接、图像路径和引用数量不得因语言校订而改变。
- 全书运行术语与残留翻译腔审计。
- 在桌面和移动视口检查目录、公式、表格、代码块和图像。
