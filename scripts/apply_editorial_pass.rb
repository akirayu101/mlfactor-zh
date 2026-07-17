#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(__dir__).parent

EDITORIAL_FILES = %w[
  index.html preface.html notdata.html intro.html factor.html Data.html
  lasso.html trees.html NN.html svm.html bayes.html valtune.html
  ensemble.html backtest.html interp.html causality.html unsup.html RL.html
  data-description.html python.html solutions-to-exercises.html
  python-notebooks.html chap_3.html chap_4.html chap_5.html chap_6.html
  chap_7.html chap_8.html chap_10.html chap_11.html chap_12.html
  chap_13.html chap_14.html chap_15.html chap_16.html
].freeze

# Ordered from specific phrases to shorter phrases so one replacement does not
# create a second, unintended match.
GLOBAL_REPLACEMENTS = [
  ["用于用于用于因子投资的机器学习", "用于因子投资的机器学习"],
  ["用于用于因子投资的机器学习", "用于因子投资的机器学习"],
  ["用于因子投资机器学习", "用于因子投资的机器学习"],
  ["因子投资中的机器学习", "用于因子投资的机器学习"],
  ["因子投资机器学习", "用于因子投资的机器学习"],
  [" | Machine Learning for Factor Investing", " | 用于因子投资的机器学习"],
  ["<a href=\"index.html\" title=\"\">Machine Learning for Factor Investing</a>", "<a href=\"index.html\" title=\"\">用于因子投资的机器学习</a>"],
  [/&lt;最后更新：([^&]+)&gt;/, "最后更新：\\1"],
  ["最小方差投资组合的惩罚回归和稀疏对冲", "惩罚回归与最小方差组合的稀疏对冲"],
  ["惩罚回归与最小方差投资组合的稀疏对冲", "惩罚回归与最小方差组合的稀疏对冲"],
  ["两个关键概念：因果性和非平稳性", "因果关系与非平稳性"],
  ["两个关键概念：因果性与非平稳性", "因果关系与非平稳性"],
  ["两个关键概念：因果关系与非平稳性", "因果关系与非平稳性"],
  ["第14章 两个关键概念：因果性与非平稳性", "第 14 章 因果关系与非平稳性"],
  ["第 14 章：因果性与非平稳性", "第 14 章：因果关系与非平稳性"],
  ["验证与调参", "模型验证与超参数调优"],
  ["超参数调参", "超参数调优"],
  ["调参", "超参数调优"],
  ["第11章 集成模型", "第 11 章 集成学习"],
  ["第 11 章：集成模型", "第 11 章：集成学习"],
  ["第 11 章 集成模型", "第 11 章 集成学习"],
  ["第13章 可解释性", "第 13 章 模型可解释性"],
  ["第 13 章：可解释性", "第 13 章：模型可解释性"],
  ["第 13 章 可解释性", "第 13 章 模型可解释性"],
  ["<span class=\"header-section-number\">1</span> 符号与数据", "<span class=\"header-section-number\">1</span> 符号约定与数据"],
  ["<span class=\"header-section-number\">1</span> 符号和数据", "<span class=\"header-section-number\">1</span> 符号约定与数据"],
  ["<span class=\"header-section-number\">2</span> 简介", "<span class=\"header-section-number\">2</span> 导论"],
  ["<span class=\"header-section-number\">2</span> 引言", "<span class=\"header-section-number\">2</span> 导论"],
  ["<span class=\"header-section-number\">3</span> 因子投资和资产定价异象", "<span class=\"header-section-number\">3</span> 因子投资与资产定价异象"],
  ["<span class=\"header-section-number\">5</span> 惩罚回归和最小方差投资组合的稀疏对冲", "<span class=\"header-section-number\">5</span> 惩罚回归与最小方差组合的稀疏对冲"],
  ["<span class=\"header-section-number\">6</span> 基于树的方法", "<span class=\"header-section-number\">6</span> 树模型"],
  ["<span class=\"header-section-number\">11</span> 集成模型", "<span class=\"header-section-number\">11</span> 集成学习"],
  ["<span class=\"header-section-number\">13</span> 可解释性", "<span class=\"header-section-number\">13</span> 模型可解释性"],
  ["<span class=\"header-section-number\">17</span> 数据描述", "<span class=\"header-section-number\">17</span> 数据说明"],
  ["<span class=\"header-section-number\">19</span> 习题解答", "<span class=\"header-section-number\">19</span> 练习解答"],
  ["<li class=\"book-part\">导论</li>", "<li class=\"book-part\">引言</li>"],
  ["<li class=\"book-part\">常见监督式算法</li>", "<li class=\"book-part\">常见监督学习算法</li>"],
  ["<li class=\"book-part\">常用监督学习算法</li>", "<li class=\"book-part\">常见监督学习算法</li>"],
  ["<li class=\"book-part\">更多重要主题</li>", "<li class=\"book-part\">其他重要主题</li>"],
  ["练习题答案", "练习解答"],
  ["练习答案", "练习解答"],
  ["记号与数据", "符号约定与数据"],
  ["过度拟合", "过拟合"],
  ["p 黑客攻击", "p 值操纵"],
  ["p黑客攻击", "p 值操纵"],
  ["没有没有没有免费午餐定理", "没有免费午餐定理"],
  ["没有没有免费午餐定理", "没有免费午餐定理"],
  ["无没有没有免费午餐定理", "没有免费午餐定理"],
  ["无没有免费午餐定理", "没有免费午餐定理"],
  ["无免费午餐定理", "没有免费午餐定理"],
  [/(?<!没有)免费午餐定理/, "没有免费午餐定理"],
  ["现代治疗方法", "现代研究体系"],
  ["现代治疗", "现代研究"],
  ["ML 引擎", "机器学习模型"],
  ["ML引擎", "机器学习模型"],
  ["ML 工具", "机器学习工具"],
  ["ML工具", "机器学习工具"],
  ["ML 社区", "机器学习社区"],
  ["ML社区", "机器学习社区"],
  ["基于ML", "基于机器学习"],
  ["专着", "专著"],
  ["金融数量", "金融变量"],
  ["金融文化", "金融常识"],
  ["语言文化", "R 语言基础"],
  ["样本外效率", "样本外表现"],
  ["标签知道特征的条件规律是不一样的", "给定特征时，标签的条件分布发生了变化"],
  ["前瞻性偏差", "前视偏差"],
  ["投资组合排序法法", "投资组合排序法"],
  ["算法系列", "算法类别"],
  ["外样本", "样本外"],
  ["买空", "做多"],
  ["负利润", "亏损"],
  ["预测器将用作", "预测变量；在统计学中也称为"],
  ["被预测</strong> 变量", "目标</strong>变量"],
  ["概率密度函数 (pdfs)", "概率密度函数（PDF）"],
  ["累积分布函数 (cdfs)", "累积分布函数（CDF）"],
  ["概率密度函数（pdfs）", "概率密度函数（PDF）"],
  ["累积分布函数（cdfs）", "累积分布函数（CDF）"],
  [/([\p{Han}]) +<(strong|em)>(?=\p{Han})/, "\\1<\\2>"],
  [/(\p{Han})<\/(strong|em)> +(?=\p{Han})/, "\\1</\\2>"],
  [/([\p{Han}])<(strong|em)>(?=[A-Za-z0-9])/, "\\1 <\\2>"],
  [/([\p{Han}]) {2,}<(strong|em)>(?=[A-Za-z0-9])/, "\\1 <\\2>"],
  [/([A-Za-z0-9)])<\/(strong|em)>(?=\p{Han})/, "\\1</\\2> "],
  [/([A-Za-z0-9)])<\/(strong|em)> {2,}(?=\p{Han})/, "\\1</\\2> "]
].freeze

FILE_REPLACEMENTS = {
  "notdata.html" => [
    ["本节旨在提供全书将使用的正式数学约定。", "本节给出全书统一采用的数学符号约定。"],
    ["我们将并行使用两种符号。第一个是纯机器学习表示法", "全书同时采用两套相互对应的记号。第一套是机器学习记号"],
    ["（也称为 <strong>输出</strong>、<strong>因变量</strong> 变量或 <strong>目标</strong>变量）", "（也称为<strong>输出</strong>、<strong>因变量</strong>或<strong>目标变量</strong>）"],
    ["<strong>实例</strong>、<strong>记录</strong>或<strong>观测</strong>", "个<strong>样本</strong>（也称<strong>记录</strong>或<strong>观测</strong>）"],
    ["<strong>属性</strong>、<strong>特征</strong>、<strong>输入</strong>或<strong>预测变量；在统计学中也称为</strong><strong>独立</strong>和<strong>解释性</strong>变量", "个<strong>属性</strong>，也就是<strong>特征</strong>或<strong>输入</strong>；在统计学中，它们也称为<strong>预测变量</strong>、<strong>自变量</strong>或<strong>解释变量</strong>"],
    ["为 <span class=\"math inline\">\(\\textbf{X}\)</span> 的一个实例（一行）编写", "将 <span class=\"math inline\">\(\\textbf{X}\)</span> 中的一个样本（即一行）记作"],
    ["或为 <span class=\"math inline\">\(\\textbf{X}\)</span> 的一个（特征）列向量编写", "将 <span class=\"math inline\">\(\\textbf{X}\)</span> 中某个特征对应的列向量记作"],
    ["一个 <strong>实例</strong>（或 <strong>观测</strong>）", "一个<strong>样本</strong>（或<strong>观测</strong>）"],
    ["将由一对（", "由一对索引（"],
    ["）一个特定日期和一个特定公司组成", "）唯一确定，即某个特定日期的一家特定公司"],
    ["因子投资中机器学习模型的目的是确定将公司的时间", "因此，因子投资中的机器学习模型旨在学习一种映射：把公司在"],
    ["特征映射到其未来绩效的模型", "时点的特征映射为其未来表现"],
    ["为了 <strong> 再现性 </strong>", "为了保证<strong>可复现性</strong>"],
    ["这些点按月频率采样", "数据按月采样"],
    ["最后四列是标签", "最后 4 列是标签"],
    ["未来/远期收益率", "未来收益率"],
    ["这是投资收益的更好代表", "因此比单纯的价格收益率更能反映投资者的实际回报"],
    ["模型根据一部分数据（<strong>训练集</strong>）进行估计，然后对另一部分数据（<strong>测试集</strong>）进行测试以评估其质量", "模型先在一部分数据（<strong>训练集</strong>）上拟合，再用另一部分数据（<strong>测试集</strong>）评估其样本外表现"]
  ],
  "intro.html" => [
    ["<span class=\"header-section-number\">2</span> 简介", "<span class=\"header-section-number\">2</span> 导论"],
    ["<title>2 简介", "<title>2 导论"],
    ["<strong>随后</strong> 涵盖的技术细节的总和更相关", "后续各章技术细节的简单汇总更重要"],
    ["远离算法，回到本节", "暂时放下算法，回到本章"],
    ["以更广泛的视角了解预测建模中的一些问题", "从更宽的视角重新审视预测建模中的关键问题"],
    ["从而预测哪些资产会表现良好，哪些资产不会", "也就是判断哪些资产未来表现较好、哪些较差"],
    ["在时间<span class=\"math inline\">\(t\)</span>计算出的时间<span class=\"math inline\">\(t+1\)</span>的", "在时点 <span class=\"math inline\">\(t\)</span> 对 <span class=\"math inline\">\(t+1\)</span> 期"],
    ["因此它与面板方法具有相似性", "因此具有面板数据模型的形式"],
    ["<strong>一体化</strong> 更为明智", "一个<strong>整体系统</strong>更为恰当"],
    ["预测的内在难点", "预测的根本困难"],
    ["有关 <strong> 随后的 </strong> 波动的模式", "<strong>未来</strong>变化的规律"],
    ["这是一个美好愿望", "但这往往只是一厢情愿"],
    ["为了说明这个悲伤的事实", "为了说明这一令人沮丧的事实"],
    ["从<strong>中提取信号</strong>", "从<strong>噪声中提取信号</strong>"],
    ["正确的问题可能是套用杰夫·贝佐斯的话：什么是不会改变的？ <strong>持久</strong>系列更有可能揭示持久的模式。", "借用杰夫·贝佐斯的问题，要提高样本外表现，或许更应该问：什么不会改变？具有长期稳定性的序列，更可能揭示可持续的规律。"],
    ["没有任何东西可以取代 <strong>实践</strong>", "任何方法都无法替代<strong>实践</strong>"]
  ],
  "Data.html" => [
    ["对于非财务数据处理的介绍", "若要了解通用的非金融数据预处理"],
    ["通用机器学习书籍", "机器学习通论"],
    ["关于该专用主题的专著", "专门讨论特征工程的著作"],
    ["重新定位", "集中"],
    ["创建一个质量点", "在某个取值处形成概率质量点"],
    ["一分为二", "划分为两类"],
    ["未来/远期", "未来"],
    ["（远期）收益率", "未来收益率"],
    ["信息最丰富的实例", "信息量最大的样本"],
    ["学习项目的选择", "训练样本的选择"]
  ],
  "lasso.html" => [
    ["在本章中，我们介绍了线性模型中广泛应用的正则化概念。", "本章介绍线性模型中广泛使用的正则化方法。"],
    ["事实上，这些模型有多种可能的应用。", "正则化线性模型在本书中有多种用途。"],
    ["利用惩罚来提高基于因子的预测回归的稳健性", "通过惩罚项提高因子预测回归的稳健性"],
    ["然后，结果可用于推动分配方案", "所得预测可进一步用于构建资产配置方案"],
    ["组合来自个体特征的预测", "组合各项公司特征产生的预测"],
    ["不受约束", "无约束"]
  ],
  "trees.html" => [
    ["分类树和回归树是简单而强大的聚类算法", "分类树和回归树是结构简单却功能强大的递归划分算法"],
    ["决策树及其扩展是非常有效的预测工具", "决策树及其扩展是处理表格数据时非常有效的预测工具"],
    ["诉诸简单树的改进", "采用树模型的扩展方法"],
    ["元研究", "荟萃研究"],
    ["将数据集划分为 <strong>同质簇</strong>", "把数据集递归划分为<strong>相对同质的组</strong>"],
    ["和特点 <span class=\"math inline\">\(\\mathbf{X}\)</span>", "和特征 <span class=\"math inline\">\(\\mathbf{X}\)</span>"],
    ["实例的比例", "样本所占比例"],
    ["所有实例", "所有样本"],
    ["集中实例", "组内样本"],
    ["观察结果", "观测"],
    ["病态案例", "难以预测的样本"],
    ["新的重量", "新的样本权重"],
    ["功能 <span class=\"math inline\">\(x\\mapsto", "函数 <span class=\"math inline\">\(x\\mapsto"],
    ["对功能进行测试", "逐一测试候选特征"],
    ["能够最小化每个给定分割目标的功能", "使每次分裂目标最小的特征"],
    ["观察到的性能", "得到的表现"]
  ],
  "NN.html" => [
    ["神经网络（NNs）是一个非常丰富和复杂的主题", "神经网络（NN）是一个内容丰富且体系庞杂的领域"],
    ["NNs 最简单架构背后的简单思想和概念", "神经网络基础架构背后的核心思想"],
    ["对于 NN 特性的更详尽的处理，我们参考了", "若要系统了解神经网络，可参阅"],
    ["首先，我们简要评论一下“神经网络”这个资格", "首先说明一下“神经网络”这一称谓"],
    ["因为我们认为它更合适，我们回顾一下", "我们认为下面这个定义更为贴切，因此引用"],
    ["为了符号简单起见", "为简化记号"],
    ["功能选择", "函数选择"],
    ["softmax</em> 功能", "softmax</em> 函数"],
    ["培训术语包括", "训练过程涉及"],
    ["万能逼近", "通用逼近"],
    ["在续集中", "下文中"],
    ["循环使用术语", "复用中间结果"],
    ["所有单元都回来了", "所有单元都会恢复启用"],
    ["RMS 传播优化器", "RMSprop 优化器"],
    ["损耗和指标", "损失和指标"]
  ],
  "svm.html" => [
    ["虽然支持向量机 (SVMs) 的起源很古老（并且可以追溯到", "支持向量机（SVM）的历史可以追溯到"],
    ["），他们的现代研究始于", "；其现代研究体系则始于"],
    [" （二元分类）和", "（二分类），以及"],
    [" （回归）。我们参考", "（回归）。关于其理论与实证性质，可参阅"],
    ["SVMs 自创建以来", "SVM 自提出以来"],
    ["<strong>保证金</strong>", "<strong>间隔</strong>"],
  ["错误变得更加惩罚", "误分类受到的惩罚越重"],
    ["修正变量", "松弛变量"],
    ["简直就是", "即为"],
    ["回收用于提升树的变量", "复用提升树一节中定义的变量"],
    ["训练速度很慢", "由于训练耗时较长"],
    ["普通的 SVM", "标准 SVM"]
  ],
  "bayes.html" => [
    ["对参数进行事先假设", "为参数指定先验分布"],
    ["简单构建块", "基本模型"],
    ["我们参考了", "可参阅"],
    ["后者与本书一样，用多行 R 代码说明了这些概念", "后一本书与本书类似，使用大量 R 代码讲解相关概念"]
  ],
  "valtune.html" => [
    ["如章节所示", "如第"],
    ["、ML 模型需要", "章所示，机器学习模型需要"],
    ["用户指定的选择", "由用户预先设定若干选项"],
    ["替代设计", "不同的模型设计"],
    ["找到正确的参数", "找到合适的超参数"],
    ["制作有效的模型", "构建有效模型"],
    ["<span class=\"header-section-number\">10.1</span> 学习指标", "<span class=\"header-section-number\">10.1</span> 模型评估指标"],
    ["<strong>有条件的</strong> 一些外部变量", "并以某些外部变量为<strong>条件</strong>"],
    ["实例重要性的异质性", "不同样本的重要性"],
    ["让我们简单评论一下MSE", "下面简要讨论 MSE"],
    [/已{2,}实现收益率{2,}/, "已实现收益率"],
    [/(?<!已)实现收益(?!率)/, "已实现收益率"],
    ["第一个术语", "第一项"],
    ["第二个控制", "第二项控制"],
    ["从分配器的角度", "从资产配置的角度"],
    ["错误实例", "负类样本"],
    ["正确实例", "正类样本"],
    ["真实实例", "正类样本"],
    ["影响率", "假阳性率"],
    ["下降率", "假阳性率"],
    ["相反的后果", "假阳性率"],
    ["后果为空", "假阳性率为零"],
    ["</span>特异度", "</span> 特异度"],
    ["获取功能", "采集函数"],
    ["我们从本章中回收了这些特征", "这里复用第"],
    ["其他人", "其余分区"],
    ["全面而详尽的浏览", "全面综述"]
  ],
  "ensemble.html" => [
    ["让我们说实话", "先坦率地说"],
    ["确定 ML 工具之间的最佳选择并不明显", "很难预先判断哪类机器学习工具最合适"],
    ["<strong>联合</strong> 几种算法", "<strong>组合</strong>多种算法"],
    ["从每个引擎（或学习器）中提取价值", "吸收各个模型（学习器）中的有效信息"],
    ["这个意图并不新鲜", "这一思路并不新鲜"],
    ["贡献的汇编", "论文合集"]
  ],
  "backtest.html" => [
    ["投资组合回测通常被认为是寻找最佳策略——或者至少是一个稳定盈利的策略", "投资组合回测通常被理解为寻找最佳策略，至少是一个能够稳定盈利的策略"],
    ["可能漫长的努力可能会诱使外行人将侥幸与强有力的策略混为一谈", "如果反复搜索而缺少约束，这一漫长过程很容易让人把偶然结果误认为稳健策略"],
    ["连续发表的两篇论文", "以下两篇相继发表的论文"],
    ["该漏洞与", "这一问题与"],
    ["对数据进行拷问", "反复挖掘数据"],
    ["选择令人愉悦的异常值", "挑中看起来最漂亮的异常结果"],
    ["错误的类型 arguably", "错误类型中，最危险的或许是"],
    ["标签的 <strong>再平衡频率</strong> 和 <strong>地平线</strong>", "<strong>再平衡频率</strong>和标签的<strong>预测期</strong>"],
    ["他们应该平等并不明显", "两者不必相等"],
    ["覆盖句点", "覆盖区间"],
    ["某个功能由", "某项特征由"],
    ["有先见之明的数据", "事后才能获得的数据"],
    ["投资组合旋转", "投资组合换手"],
    ["发射重量", "初始建仓权重"],
    ["所需的 <span class=\"math inline\">\(t\)</span> 时间权重", "在时点 <span class=\"math inline\">\(t\)</span> 的目标权重"],
    ["统一配置", "等权配置"],
    ["统一投资组合", "等权投资组合"],
    ["产品组合级别", "投资组合层面"],
    ["机器学习模型级别", "机器学习模型层面"],
    ["无法超越", "往往难以超越"],
    ["一致击败", "持续击败"],
    ["很好的猜测", "正确判断"],
    ["最后，一个重要的精度", "最后补充一个重要细节"],
    ["oracle 函数", "预言机函数"],
    ["高级策略", "复杂策略"],
    ["伤害较小", "亏损也相对较小"]
  ],
  "interp.html" => [
    ["有助于理解模型将输入处理为输出的方式的技术", "帮助我们理解模型如何把输入转化为输出的方法"],
    ["强烈建议看一下", "强烈推荐"],
    ["采用面向因子投资的语气", "从因子投资的视角展开"],
    ["白盒复杂机器学习模型", "打开复杂机器学习模型的“黑箱”"],
    ["一个特定实例", "某个具体样本"]
  ],
  "causality.html" => [
    ["无法揭示特征和标签之间的 <strong>因果性</strong> 关系", "难以揭示特征与标签之间的<strong>因果关系</strong>"],
    ["相关性比因果性弱得多", "相关关系所表达的信息远弱于因果关系"],
    ["时尚的例子", "常见例子"],
    ["因果性驱动的测试", "因果检验"],
    ["我们参考", "可参阅"],
    ["深入探讨这个主题", "对该主题作系统了解"],
    ["特征工程过程", "特征工程"],
    ["标签知道特征的条件规律是不一样的", "给定特征时，标签的条件分布发生了变化"],
    ["主要问题可能是概念漂移", "更棘手的问题通常是概念漂移"],
    ["遗憾：", "累计遗憾值："],
    ["<p>[[<strong>说明</strong>：本小节其余内容仍在修订。]]</p>", "<p><strong>实现说明：</strong>原版采用已从 CRAN 下架的 <em>CAM</em> 软件包。这里改用 <em>InvariantCausalPrediction</em> 演示可运行的替代方案；两者方法不同，输出不应直接比较。</p>"]
  ],
  "unsup.html" => [
    ["属于较大类别的监督学习工具", "都属于监督学习方法"],
    ["揭示预测变量", "学习预测变量"],
    ["要求数据试图解释这个特定的变量", "学习目标被明确指定为解释变量"],
    ["算法尝试自行理解", "算法自行从"],
    ["的另一个重要部分包括无监督学习任务", "的另一大分支是无监督学习"],
    ["在数据预处理阶段", "在数据预处理环节"]
  ],
  "RL.html" => [
    ["由于强化学习 (RL) 在机器学习社区中越来越受欢迎", "随着强化学习（RL）在机器学习社区中日益受到重视"],
    ["仅 2019 年", "仅在 2019 年"],
    ["市场微观结构是一个焦点框架", "市场微观结构是其中一个重点应用场景"],
    ["强化学习不仅仅是一种特定算法，而是一个框架", "强化学习与其说是一种具体算法，不如说是一套问题框架"],
    ["有效应用并不简单", "有效落地并不容易"],
    ["若令<span class=\"math inline\">", "若令 <span class=\"math inline\">"],
    ["就可以通过<span class=\"math inline\">", "就可以通过 <span class=\"math inline\">"],
    ["</span>以线性形式编码因子或特征", "</span> 以线性形式编码因子或特征"]
  ],
  "solutions-to-exercises.html" => [
    ["测试版", "贝塔"],
    ["统一（EW）值", "等权（EW）配置"],
    ["回收该函数", "复用该函数"],
    ["回收用于", "复用用于"],
    ["负状态与巨额利润相关", "负状态对应较高收益"],
    ["正状态具有最佳平均奖励", "正状态下的平均奖励最高"]
  ],
  "python.html" => [
    ["Python notebook 中文版", "Python Notebook 中文版"],
    ["中文 notebook", "中文 Notebook"]
  ],
  "python-notebooks.html" => [
    ["Python notebooks 中文版", "Python Notebook 中文版"],
    ["Python notebook", "Python Notebook"],
    ["中文 notebook", "中文 Notebook"]
  ],
  "chap_5.html" => [
    ["<title>第5章</title>", "<title>第 5 章 惩罚回归与最小方差组合的稀疏对冲</title>"]
  ],
  "chap_6.html" => [
    ["<title>第6章</title>", "<title>第 6 章 树模型</title>"]
  ],
  "chap_7.html" => [
    ["<title>第7章</title>", "<title>第 7 章 神经网络</title>"]
  ],
  "chap_8.html" => [
    ["<title>第8章</title>", "<title>第 8 章 支持向量机</title>"]
  ],
  "chap_12.html" => [
    ["<title>第 12 章 组合回测</title>", "<title>第 12 章 投资组合回测</title>"]
  ]
}.freeze

METADATA_DESCRIPTIONS = {
  "lasso.html" => "本章介绍惩罚回归、正则化路径，以及最小方差投资组合中的稀疏对冲。",
  "trees.html" => "本章介绍决策树、随机森林、AdaBoost 与 XGBoost，并讨论它们在因子投资中的应用。",
  "NN.html" => "本章介绍神经网络的基本结构、训练方法、正则化，以及用于收益率预测的 R 实现。",
  "svm.html" => "本章介绍支持向量机的间隔、核技巧与松弛变量，以及分类和回归应用。",
  "bayes.html" => "本章介绍贝叶斯方法中的先验、似然、后验、朴素贝叶斯与贝叶斯加性回归树。",
  "valtune.html" => "本章介绍模型评估指标、交叉验证、超参数网格搜索与贝叶斯优化。",
  "ensemble.html" => "本章介绍集成学习，以及如何通过平均、堆叠和动态选择组合多个模型。",
  "backtest.html" => "本章介绍投资组合回测、前视偏差、交易成本、换手率与回测过拟合。",
  "interp.html" => "本章介绍代理模型、特征重要性、部分依赖图、LIME 与 Shapley 值。",
  "causality.html" => "本章讨论因果关系、格兰杰因果检验、因果图，以及金融数据中的非平稳性。",
  "unsup.html" => "本章介绍无监督学习中的自编码器、主成分分析、聚类与最近邻方法。",
  "RL.html" => "本章介绍强化学习的基本框架、马尔可夫决策过程、Q 学习及其金融应用。"
}.freeze

FOOTER_DATES = {
  "index.html" => "2023 年 7 月 17 日",
  "preface.html" => "2022 年 10 月 18 日",
  "notdata.html" => "2022 年 10 月 18 日",
  "intro.html" => "2022 年 10 月 18 日",
  "factor.html" => "2023 年 7 月 17 日",
  "Data.html" => "2022 年 10 月 18 日",
  "lasso.html" => "2022 年 10 月 18 日",
  "trees.html" => "2022 年 10 月 18 日",
  "NN.html" => "2022 年 10 月 18 日",
  "svm.html" => "2022 年 10 月 18 日",
  "bayes.html" => "2022 年 10 月 18 日",
  "valtune.html" => "2022 年 10 月 18 日",
  "ensemble.html" => "2023 年 7 月 17 日",
  "backtest.html" => "2022 年 10 月 18 日",
  "interp.html" => "2022 年 10 月 18 日",
  "causality.html" => "2022 年 10 月 18 日",
  "unsup.html" => "2022 年 10 月 18 日",
  "RL.html" => "2022 年 10 月 18 日",
  "data-description.html" => "2022 年 10 月 18 日",
  "python.html" => "2022 年 11 月 28 日",
  "solutions-to-exercises.html" => "2022 年 10 月 18 日"
}.freeze

def apply_replacements(html, replacements)
  total = 0
  replacements.each do |source, target|
    count = html.scan(source).length
    next if count.zero?

    html.gsub!(source, target)
    total += count
  end
  [html, total]
end

def replace_if_different(html, pattern, target)
  count = 0
  html.gsub!(pattern) do |current|
    next current if current == target

    count += 1
    target
  end
  [html, count]
end

def update_metadata(html, description)
  count = 0
  {
    /<meta content="[^"]*" name="description"\/>/ => %(<meta content="#{description}" name="description"/>),
    /<meta content="[^"]*" property="og:description"\/>/ => %(<meta content="#{description}" property="og:description"/>),
    /<meta content="[^"]*" name="twitter:description"\/>/ => %(<meta content="#{description}" name="twitter:description"/>),
  }.each do |pattern, target|
    html, replacements = replace_if_different(html, pattern, target)
    count += replacements
  end
  [html, count]
end

def update_footer(html, date)
  target = %(<p>《<strong>用于因子投资的机器学习</strong>》由 Guillaume Coqueret 和 Tony Guida 撰写，原版页面最后构建于 #{date}。</p>)
  pattern = %r{<p>[“"《]<strong>(?:Machine Learning for Factor Investing|用于因子投资的机器学习)</strong>.*?(?:最后|它最后).*?</p>}
  html, count = replace_if_different(html, pattern, target)

  incomplete = %(<p>本书由 <a class="text-light" href="https://bookdown.org">bookdown</a> R 包。</p>)
  complete = %(<p>本书使用 <a class="text-light" href="https://bookdown.org">bookdown</a> R 包构建。</p>)
  html, bookdown_count = replace_if_different(html, Regexp.new(Regexp.escape(incomplete)), complete)
  [html, count + bookdown_count]
end

total = 0
EDITORIAL_FILES.each do |name|
  path = ROOT.join(name)
  html = path.read(encoding: "UTF-8")
  html, global_count = apply_replacements(html, GLOBAL_REPLACEMENTS)
  html, file_count = apply_replacements(html, FILE_REPLACEMENTS.fetch(path.basename.to_s, []))
  html, metadata_count = update_metadata(html, METADATA_DESCRIPTIONS.fetch(path.basename.to_s)) if METADATA_DESCRIPTIONS.key?(path.basename.to_s)
  metadata_count ||= 0
  html, footer_count = update_footer(html, FOOTER_DATES.fetch(path.basename.to_s)) if FOOTER_DATES.key?(path.basename.to_s)
  footer_count ||= 0
  count = global_count + file_count + metadata_count + footer_count
  next if count.zero?

  path.write(html, encoding: "UTF-8")
  total += count
  puts "%4d  %s" % [count, path.basename]
end

puts "Applied #{total} editorial replacements."
