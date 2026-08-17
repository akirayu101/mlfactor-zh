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
| instance / observation | 样本 / 观测 | `instance` 指机器学习输入行时译为“样本”；`observation` 指资产—日期数据点时译为“观测”；不译为“实例” |
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
| prior distribution | 先验分布 | 首次出现和章节标题不得只写“先验” |
| prior probability | 先验概率 | 分类语境中通常指类别的先验概率 |
| prior predictive distribution | 先验预测分布 | 与后验预测分布区分 |
| likelihood / likelihood function | 似然 / 似然函数 | 指关于参数的函数时优先写“似然函数” |
| marginal likelihood | 边际似然 | 也称模型证据；不得只译为“概率” |
| posterior distribution | 后验分布 | 首次出现和章节标题不得只写“后验” |
| posterior probability | 后验概率 | 分类或假设比较语境使用 |
| posterior predictive distribution | 后验预测分布 | 不简写为“后验预测”造成对象不明 |
| conjugate prior | 共轭先验分布 | 后文对象明确时可简称“共轭先验” |
| credible interval | 可信区间 | 不与频率学派的“置信区间”混用 |
| Bayes factor | 贝叶斯因子 | |
| precision matrix | 精度矩阵 | 即协方差矩阵的逆 |
| sampling distribution | 抽样分布 | 与样本分布、后验分布区分 |
| out-of-sample / in-sample | 样本外 / 样本内 | |
| validation set | 验证集 | 与测试集区分 |
| hyperparameter tuning | 超参数调优 | 不用“调参”作标题 |
| loss function / objective function | 损失函数 / 目标函数 | 二者不应笼统译成“指标” |
| performance metric | 评估指标 | performance 需按模型或投资组合语境处理 |
| ensemble | 集成 / 集成学习 | |
| learner / weak learner | 学习器 / 弱学习器 | |
| tree-based methods | 树模型 / 基于树的方法 | |
| recursive partitioning | 递归划分 | 树模型语境 |
| split / split point | 分裂 / 分裂点 | 不译为“分割功能” |
| leaf / terminal node | 叶节点 | |
| impurity | 不纯度 | 分类树语境 |
| activation function | 激活函数 | 不将具体激活函数统称为“线性激活函数” |
| rectified linear unit (ReLU) | 修正线性单元（ReLU） | 可补充说明其函数形式为 `max(0,x)`；不译为“线形激活函数” |
| backpropagation | 反向传播 | |
| dropout | Dropout（随机失活） | 首次出现保留英文；后文可简称 Dropout |
| optimizer | 优化器 | |
| mini-batch | 小批量 | |
| margin (SVM) | 间隔 | 不译为“保证金” |
| kernel / kernel trick | 核函数 / 核技巧 | |
| slack variable | 松弛变量 | |
| support vector | 支持向量 | |
| principal component analysis (PCA) | 主成分分析（PCA） | |
| explained variance ratio | 方差解释率 | |
| autoencoder | 自编码器 | |
| latent representation | 潜在表示 | |
| clustering | 聚类 | |
| data snooping | 数据窥探 | |
| p-hacking | p 值操纵 | |
| look-ahead bias | 前视偏差 | |
| survivorship bias | 幸存者偏差 | |
| overfitting | 过拟合 | 不用“过度拟合” |
| turnover | 换手率 | |
| transaction cost | 交易成本 | |
| benchmark | 基准 | |
| drawdown / maximum drawdown | 回撤 / 最大回撤 | |
| factor exposure / factor premium | 因子暴露 / 因子溢价 | 不把 exposure 译为“风险敞口”，除非上下文明确强调风险 |
| factor loading | 因子载荷 | 与一般投资组合暴露区分 |
| excess return | 超额收益率 | 与绝对收益率区分 |
| portfolio weight | 投资组合权重 | 不译为“重量” |
| equal-weighted / value-weighted | 等权 / 市值加权 | |
| cross-sectional regression | 横截面回归 | |
| time-series regression | 时间序列回归 | |
| interpretability | 模型可解释性 | |
| causality | 因果关系 | “因果性”仅在强调性质时使用 |
| non-stationarity | 非平稳性 | |
| covariate shift | 协变量偏移 | |
| concept drift | 概念漂移 | |
| directed acyclic graph (DAG) | 有向无环图（DAG） | |
| confounder / confounding variable | 混杂变量 | |
| intervention / treatment | 干预 / 处理 | 依因果推断语境选择，不译为“治疗”，除非确指医疗处理 |
| counterfactual | 反事实 | |
| mediator / collider | 中介变量 / 碰撞点 | |
| regret (online learning) | 遗憾值 | |
| state / action / reward | 状态 / 动作 / 奖励 | 强化学习语境 |
| policy / value function | 策略 / 价值函数 | |
| exploration-exploitation | 探索与利用 | |
| floor function | 向下取整函数 | 不用含义不明确的“整数部分函数”或“取整函数” |
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

## 术语选择规则

- 先识别术语所修饰或指代的统计对象，再确定中文名词。不得把英文形容词机械名词化。例如，`prior` 可能是“先验分布”“先验概率”或“先验设定”，`posterior` 可能是“后验分布”“后验概率”或“后验预测分布”。
- 章节标题、首次定义和跨段重新引入概念时使用完整术语。只有在同一段落中指代已经明确时，才可将“先验分布”“后验分布”简称为“先验”“后验”。
- `confidence interval` 译为“置信区间”，`credible interval` 译为“可信区间”；二者反映不同的概率解释，不得互换。
- `estimate`、`estimator` 和 `estimation` 分别按上下文译为“估计值”“估计量”和“估计/估计过程”，不能统一写成“估计”。
- 面板数据与机器学习记号相互转换时，统一表述为“第 `i` 个样本对应面板数据中的一条资产—日期观测 `(t,n)`”。矩阵的一行称“样本”，具体资产在具体日期的数据点称“观测”；`training/validation/test sample` 作为数据集整体时译为“训练集/验证集/测试集”；`instance weighting` 译为“样本加权”，单个 `weight` 译为“样本权重”。
- `expected return`、`realized return`、`forward return` 和 `excess return` 分别译为“预期收益率”“已实现收益率”“未来收益率”和“超额收益率”。
- `performance` 没有固定译法：模型语境通常译为“表现”或“预测性能”，投资语境通常译为“业绩”或“投资表现”，不得一律译为“绩效”。

## 校订验收

- 每章逐段与官方英文页面对照。
- 数学公式、代码块、链接、图像路径和引用数量不得因语言校订而改变。
- 全书运行术语与残留翻译腔审计。
- 在桌面和移动视口检查目录、公式、表格、代码块和图像。
