#!/usr/bin/env ruby2.1

require 'rexml/document'
require 'data_mapper'
require_relative "../lib/rubydas/model/feature"

def make_db_path
	'sqlite://' << File.expand_path('..') << '/' << ARGV[0]
end

DataMapper.setup(:default, make_db_path)
adapter = DataMapper.repository(:default).adapter

existing_types = FeatureType.all().map { |t| (t.label != "") ? t.label : nil }.compact

def rand_color
"#" << rand(0xFFFFFF).to_s(16)
end

def make_type(id, color)
doc = REXML::Document.new "<TYPE id=\"#{id}\">\n<GLYPH>\n<BOX>\n<HEIGHT>11</HEIGHT>\n<FGCOLOR>black</FGCOLOR>\n<BGCOLOR>#{color}</BGCOLOR>\n<BUMP>yes</BUMP>\n<LABEL>yes</LABEL>\n</BOX></GLYPH></TYPE>\n"
doc.elements["TYPE"]
end

stylesheet = File.open("../lib/rubydas/views/templates/styles.xml", "r")
style_doc = REXML::Document.new stylesheet
stylesheet.close
style_doc_root = style_doc.root

TYPES_PATH = "DASSTYLE/STYLESHEET/CATEGORY/TYPE"

pre_loaded_types = []

style_doc.elements.each(TYPES_PATH) do |elem|
	pre_loaded_types.push(elem.attributes["id"])
end

#Defined in DB but not pre-defined in styles.xml
@missing = existing_types - pre_loaded_types

#Defined in styles.xml but not in DB
@redundant = pre_loaded_types - existing_types

@missing.each do |type|
new_elem = style_doc.elements[TYPES_PATH.chomp "/TYPE"].add(make_type(type, rand_color))
new_elem.add_attribute("id", type)
end

@redundant.each do |type|
style_doc.elements.delete("#{TYPES_PATH}[@id='#{type}']")
end

puts make_db_path

File.open("../public/styles.xml", "w") { |f| f << style_doc.to_s}

File.open("../public/index.html", "w") { |f| f << File.open("../lib/rubydas/views/templates/index.html", "r") { |f| f.read }}
File.open("../public/main.css", "w") { |f| f << File.open("../lib/rubydas/views/templates/main.css", "r") { |f| f.read }}
