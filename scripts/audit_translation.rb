#!/usr/bin/env ruby
# frozen_string_literal: true

require "nokogiri"
require "json"
require "digest"
require "open3"
require "pathname"

ROOT = Pathname.new(__dir__).parent
UPSTREAM = ENV["MLFACTOR_UPSTREAM"] && Pathname.new(ENV.fetch("MLFACTOR_UPSTREAM"))
STRUCTURE_BASELINE = ROOT.join("docs/translation-structure.json")
INTEGRITY_BASELINE = ROOT.join("docs/translation-integrity.json")

BOOK_FILES = %w[
  index.html preface.html notdata.html intro.html factor.html Data.html
  lasso.html trees.html NN.html svm.html bayes.html valtune.html
  ensemble.html backtest.html interp.html causality.html unsup.html RL.html
  data-description.html python.html solutions-to-exercises.html
].freeze

NOTEBOOK_FILES = %w[
  python-notebooks.html chap_3.html chap_4.html chap_5.html chap_6.html
  chap_7.html chap_8.html chap_10.html chap_11.html chap_12.html
  chap_13.html chap_14.html chap_15.html chap_16.html
].freeze

EXPECTED_HEADINGS = {
  "index.html" => "前言",
  "preface.html" => "前言",
  "notdata.html" => "符号约定与数据",
  "intro.html" => "导论",
  "factor.html" => "因子投资与资产定价异象",
  "Data.html" => "数据预处理",
  "lasso.html" => "惩罚回归与最小方差组合的稀疏对冲",
  "trees.html" => "树模型",
  "NN.html" => "神经网络",
  "svm.html" => "支持向量机",
  "bayes.html" => "贝叶斯方法",
  "valtune.html" => "模型验证与超参数调优",
  "ensemble.html" => "集成学习",
  "backtest.html" => "投资组合回测",
  "interp.html" => "模型可解释性",
  "causality.html" => "因果关系与非平稳性",
  "unsup.html" => "无监督学习",
  "RL.html" => "强化学习",
  "data-description.html" => "数据说明",
  "python.html" => "Python",
  "solutions-to-exercises.html" => "练习解答"
}.freeze

EXPECTED_NAV_LABELS = {
  "notdata.html" => "1 符号约定与数据",
  "intro.html" => "2 导论",
  "factor.html" => "3 因子投资与资产定价异象",
  "Data.html" => "4 数据预处理",
  "lasso.html" => "5 惩罚回归与最小方差组合的稀疏对冲",
  "trees.html" => "6 树模型",
  "NN.html" => "7 神经网络",
  "svm.html" => "8 支持向量机",
  "bayes.html" => "9 贝叶斯方法",
  "valtune.html" => "10 模型验证与超参数调优",
  "ensemble.html" => "11 集成学习",
  "backtest.html" => "12 投资组合回测",
  "interp.html" => "13 模型可解释性",
  "causality.html" => "14 因果关系与非平稳性",
  "unsup.html" => "15 无监督学习",
  "RL.html" => "16 强化学习",
  "data-description.html" => "17 数据说明",
  "python.html" => "18 Python 笔记本",
  "solutions-to-exercises.html" => "19 练习解答"
}.freeze

FORBIDDEN = {
  "现代治疗" => "treatment 的误译",
  "p 黑客攻击" => "p-hacking 的误译",
  "过度拟合" => "统一使用“过拟合”",
  "ML 引擎" => "统一使用“机器学习模型”",
  "ML引擎" => "统一使用“机器学习模型”",
  "金融数量" => "应按语境译为“金融变量/指标”",
  "金融文化" => "应为“金融常识/基础”",
  "语言文化" => "应为“R 语言基础”",
  "专着" => "错别字，应为“专著”",
  "样本外效率" => "通常应为“样本外表现”",
  "标签知道特征" => "条件分布的误译",
  "错误变得更加惩罚" => "明显翻译腔",
  "简直就是" => "技术正文中的口语化误译",
  "从<strong>中提取信号" => "缺失“噪声”",
  "无没有" => "重复否定",
  "没有没有" => "重复否定",
  "排序法法" => "重复字",
  "进行投资组合排序法" => "应使用动词“排序”，不应把方法名称直接接在“进行”之后",
  "对投资组合排序法" => "应使用“对股票排序”或“采用投资组合排序法”",
  "用于用于" => "重复词",
  "已已" => "重复字",
  "收益率率" => "重复字",
  "真实实例" => "分类语境应为“正类样本”",
  "错误实例" => "分类语境应为“负类样本”",
  "正确实例" => "分类语境应为“正类样本”",
  "影响率" => "ROC 语境应为“假阳性率”",
  "下降率" => "ROC 语境应为“假阳性率”",
  "获取功能" => "acquisition function 应为“采集函数”",
  "发射重量" => "initial weights 的误译",
  "标签的地平线" => "horizon 应为“预测期”",
  "产品组合级别" => "portfolio level 的误译",
  "现代研究治疗" => "treatment 的误译",
  "测试版" => "金融 beta 不应译为软件测试版",
  "这个资格" => "qualification 的误译",
  "本小节其余内容仍在修订" => "内部编辑占位说明不应出现在发布版本中",
  "重量" => "机器学习与组合语境统一使用“权重”"
}.freeze

def content_counts(document)
  content = document.at_css("main#content") || document.at_css("body")
  {
    math: content.css("span.math, .MathJax, .MathJax_Display").length,
    code: content.css("pre, code").length,
    images: content.css("img").length,
    links: content.css("a").length,
    blocks: content.css("p, li, h1, h2, h3, h4, th, td, figcaption").length
  }
end

def digest_items(items)
  Digest::SHA256.hexdigest(items.join("\u0000"))
end

def integrity_fingerprint(document)
  content = document.at_css("main#content") || document.at_css("body")
  {
    "math" => digest_items(content.css("span.math").map(&:to_html)),
    "code" => digest_items(content.css("pre, code").map(&:to_html)),
    "images" => digest_items(content.css("img").map { |node| node["src"].to_s }),
    "links" => digest_items(content.css("a").map { |node| node["href"].to_s }),
    "ids" => digest_items(content.css("[id]").map { |node| node["id"].to_s })
  }
end

write_integrity_index = ARGV.index("--write-integrity-from-git")
if write_integrity_index
  revision = ARGV.fetch(write_integrity_index + 1, "HEAD")
  integrity = {}
  (BOOK_FILES + NOTEBOOK_FILES).each do |name|
    html, status = Open3.capture2("git", "show", "#{revision}:#{name}", chdir: ROOT.to_s)
    next unless status.success?

    integrity[name] = integrity_fingerprint(Nokogiri::HTML(html))
  end
  INTEGRITY_BASELINE.write(JSON.pretty_generate(integrity) + "\n")
  puts "Wrote #{INTEGRITY_BASELINE.relative_path_from(ROOT)} from #{revision}"
  ARGV.slice!(write_integrity_index, 2)
end

errors = []
warnings = []
files = BOOK_FILES + NOTEBOOK_FILES
baseline = STRUCTURE_BASELINE.file? ? JSON.parse(STRUCTURE_BASELINE.read) : {}
integrity_baseline = INTEGRITY_BASELINE.file? ? JSON.parse(INTEGRITY_BASELINE.read) : {}
current_structure = {}

files.each do |name|
  path = ROOT.join(name)
  unless path.file?
    errors << "#{name}: 文件不存在"
    next
  end

  html = path.read(encoding: "UTF-8")
  document = Nokogiri::HTML(html)
  lang = document.at_css("html")&.[]("lang")
  errors << "#{name}: html lang=#{lang.inspect}" unless lang == "zh-CN"

  page_title = document.at_css("title")&.text.to_s.gsub(/\s+/, " ").strip
  if page_title.include?("Machine Learning for Factor Investing")
    errors << "#{name}: 浏览器标题仍使用英文书名"
  end
  if page_title.match?(/\A第\s*\d+\s*章\z/)
    errors << "#{name}: 浏览器标题缺少章节名称"
  end
  if document.css('a[href="index.html"]').any? { |node| node.text.strip == "Machine Learning for Factor Investing" }
    errors << "#{name}: 页眉仍使用英文书名"
  end
  if document.css('a[href="intro.html"]').any? { |node| node.text.match?(/\A2\s+简介\z/) }
    errors << "#{name}: 目录中的第 2 章标题应为“导论”"
  end
  EXPECTED_NAV_LABELS.each do |href, expected_label|
    document.css(".book-toc a[href='#{href}']").each do |node|
      actual_label = node.text.gsub(/\s+/, " ").strip
      next if actual_label == expected_label

      errors << "#{name}: 目录链接 #{href} 应为“#{expected_label}”，实际为“#{actual_label}”"
    end
  end

  if EXPECTED_HEADINGS.key?(name)
    heading = document.at_css("main#content h1")&.text.to_s.gsub(/\s+/, " ").strip
    unless heading.include?(EXPECTED_HEADINGS.fetch(name))
      errors << "#{name}: 章标题应包含“#{EXPECTED_HEADINGS.fetch(name)}”，实际为“#{heading}”"
    end
  end

  text = (document.at_css("main#content") || document.at_css("body"))&.text.to_s
  FORBIDDEN.each do |phrase, reason|
    errors << "#{name}: 残留“#{phrase}”（#{reason}）" if text.include?(phrase)
  end
  if text.match?(/(?<!没有)免费午餐定理/)
    errors << "#{name}: 残留“免费午餐定理”（统一使用“没有免费午餐定理”）"
  end
  emphasis_spacing_error = html.match?(/[\p{Han}] +<(?:strong|em)>(?=\p{Han})/) ||
    html.match?(/\p{Han}<\/(?:strong|em)> +(?=\p{Han})/) ||
    html.match?(/\p{Han}<(?:strong|em)>(?=[A-Za-z0-9])/) ||
    html.match?(/[A-Za-z0-9)]<\/(?:strong|em)>(?=\p{Han})/)
  if emphasis_spacing_error
    errors << "#{name}: 中文与强调标签之间的中英文空格不符合规范"
  end

  current_counts = content_counts(document)
  current_structure[name] = current_counts.transform_keys(&:to_s)
  if baseline.key?(name)
    %w[math code images links].each do |key|
      next if current_structure[name][key] == baseline[name][key]

      errors << "#{name}: #{key} 数量变化 #{baseline[name][key]} -> #{current_structure[name][key]}"
    end
    if current_structure[name]["blocks"] != baseline[name]["blocks"]
      warnings << "#{name}: 正文块数量变化 #{baseline[name]["blocks"]} -> #{current_structure[name]["blocks"]}"
    end
  end

  if integrity_baseline.key?(name)
    current_integrity = integrity_fingerprint(document)
    integrity_baseline.fetch(name).each do |kind, expected_digest|
      next if current_integrity[kind] == expected_digest

      errors << "#{name}: #{kind} 内容或顺序与校订前基线不一致"
    end
  end

  document.css("a[href], img[src], script[src], link[href]").each do |node|
    attr = node.name == "a" || node.name == "link" ? "href" : "src"
    target = node[attr].to_s.split("#", 2).first.to_s.split("?", 2).first.to_s
    next if target.empty? || target.match?(%r{\A(?:https?:|mailto:|javascript:|data:|#)})

    decoded = target.gsub("%20", " ")
    errors << "#{name}: 本地资源不存在 #{target}" unless ROOT.join(decoded).exist?
  end

  next unless UPSTREAM

  original_path = UPSTREAM.join(name)
  next unless original_path.file?

  original = Nokogiri::HTML(original_path.read(encoding: "UTF-8"))
  original_counts = content_counts(original)
  %i[math code images].each do |key|
    next if current_counts[key] == original_counts[key]

    warnings << "#{name}: 与英文发布版的 #{key} 数量不同 #{original_counts[key]} -> #{current_counts[key]}"
  end
  if current_counts[:blocks] != original_counts[:blocks]
    warnings << "#{name}: 正文块数量变化 #{original_counts[:blocks]} -> #{current_counts[:blocks]}"
  end
end

if ARGV.delete("--write-baseline")
  STRUCTURE_BASELINE.write(JSON.pretty_generate(current_structure) + "\n")
  puts "Wrote #{STRUCTURE_BASELINE.relative_path_from(ROOT)}"
end

puts "Translation audit: #{files.length} files"
warnings.each { |message| puts "WARN  #{message}" }
errors.each { |message| puts "ERROR #{message}" }
puts errors.empty? ? "PASS" : "FAIL (#{errors.length} errors)"

exit(errors.empty? ? 0 : 1)
