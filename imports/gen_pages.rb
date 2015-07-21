#!/usr/bin/env ruby2.1

require 'rexml/document'
require 'data_mapper'
require 'erb'
require 'fileutils'
require_relative "../lib/rubydas/model/feature"
require_relative "../lib/rubydas/model/sequence"

TEMPL_PATH = File.expand_path("../lib/rubydas/views/templates") << '/'

db_path = 'sqlite://' << File.expand_path('..') << '/' << ARGV[0] << '.db'
folder_path = File.expand_path('../public/' << ARGV[0].split("/")[1])

FileUtils.mkdir_p(folder_path)

puts db_path
puts folder_path

DataMapper.setup(:default, db_path)
#adapter = DataMapper.repository(:default).adapter

existing_types = FeatureType.all().map { |t| (t.label != "") ? t.label : nil }.compact
existing_eps = Sequence.all()

def rand_color
	"#" << rand(0xFFFFFF).to_s(16)
end

def make_type(id, color)
	doc = REXML::Document.new "<TYPE id=\"#{id}\">\n<GLYPH>\n<BOX>\n<HEIGHT>11</HEIGHT>\n<FGCOLOR>black</FGCOLOR>\n" \
							  "<BGCOLOR>#{color}</BGCOLOR>\n<BUMP>yes</BUMP>\n<LABEL>yes</LABEL>" \
							  "\n</BOX></GLYPH></TYPE>\n"
	doc.elements["TYPE"]
end

def make_range(size)
	#Difference between start and end should be no greater than 10e6 to avoid timeout
	puts size
	if size > 10**6.to_i
		return (size - 10**6).to_i, size - 1 
	else
		return 1, size - 1
	end	
end

##Styles

stylesheet = File.read(TEMPL_PATH + "styles.xml")
style_doc = REXML::Document.new stylesheet
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

File.write(folder_path + "/styles.xml", style_doc.to_s)

##Index

#Maybe later:
#existing_eps.each do |e|

name = ARGV[0].split("/")[1]
chr = existing_eps[0].public_id
viewStart, viewEnd = make_range(existing_eps[0].length)
	
templ = ERB.new(File.read(TEMPL_PATH + "/index.html.erb"))
File.write(folder_path << "/index.html", templ.result)

