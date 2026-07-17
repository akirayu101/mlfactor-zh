#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "nokogiri"
require "pathname"

root = Pathname.new(__dir__).parent
page = ARGV.shift
upstream = Pathname.new(ENV.fetch("MLFACTOR_UPSTREAM", "/tmp/mlfactor-upstream-translate"))

abort "Usage: ruby scripts/extract_bilingual_review.rb PAGE.html" unless page

translated_path = root.join(page)
original_path = upstream.join(page)
abort "Missing #{translated_path}" unless translated_path.file?
abort "Missing #{original_path}" unless original_path.file?

selector = "main#content p, main#content li, main#content h1, main#content h2, " \
           "main#content h3, main#content h4, main#content th, main#content td, " \
           "main#content figcaption"

def blocks(path, selector)
  document = Nokogiri::HTML(path.read(encoding: "UTF-8"))
  document.css(selector).map do |node|
    [node.name, node.text.gsub(/\s+/, " ").strip]
  end
end

translated = blocks(translated_path, selector)
original = blocks(original_path, selector)
count = [translated.length, original.length].max

puts %w[index tag chinese english].join("\t")
count.times do |index|
  tag, chinese = translated.fetch(index, ["", ""])
  _, english = original.fetch(index, ["", ""])
  row = [index + 1, tag, chinese, english].map { |value| value.to_s.gsub("\t", " ") }
  puts row.join("\t")
end

warn "Block count differs: zh=#{translated.length}, en=#{original.length}" if translated.length != original.length
