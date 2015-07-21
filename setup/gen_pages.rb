#!/usr/bin/env ruby2.1

require 'rexml/document'
require 'data_mapper'
require 'erb'
require 'fileutils'
require 'json'
require 'builder'
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
	#Difference between start and end should be no greater than 10e5 to not start on cluttered features
	#Sometimes greater than 10e6 could lead to Dalliance timeout.
	if size > 10**5.to_i
		return (size - 10**5).to_i, size - 1 
	else
		return 1, size - 1
	end	
end

pre_loaded_styles = JSON.parse(File.read("../lib/rubydas/views/templates/styles.json"))
pre_loaded_types = Hash.new

pre_loaded_styles.each do |elem|
	pre_loaded_types.merge!(elem)
end

used_types = Hash.new

existing_types.each do |key, value|
	if pre_loaded_types.has_key? key
		used_types[key] = pre_loaded_types[key]
	else
		pre_loaded_types[key] = ["box", rand_color]
	end
end


f = File.open(folder_path + "/styles.xml", "w")

xml = Builder::XmlMarkup.new(:target => f, :indent => 4)

xml.instruct! :xml, :version => "1.0", :standalone => "yes"
xml.DASSTYLE do 
	xml.STYLESHEET do 
		xml.CATEGORY :id => "default" do
			
			used_types.each do |type, annotations|
				xml.TYPE :id => type do
					xml.GLYPH do

						if annotations[0] == "box"
							xml.BOX do
								xml.HEIGHT "11"
								xml.FGCOLOR "black"
								xml.BGCOLOR annotations[1]
								xml.BUMP "yes"
								xml.LABEL "yes"
							end
						elsif annotations[0] == "line"
							xml.LINE do 
								xml.HEIGHT "11"
								xml.FGCOLOR "black"
								xml.BGCOLOR annotations[1]
								xml.BUMP "yes"
								xml.LABEL "yes"
							end
						else
							raise ArgumentError.new("disaster")
						end
					end
				end
			end
		end
	end
end

f.close

##Index

#Maybe later:
#existing_eps.each do |e|

name = ARGV[0].split("/")[1]
chr = existing_eps[0].public_id
viewStart, viewEnd = make_range(existing_eps[0].length)
	
templ = ERB.new(File.read(TEMPL_PATH + "/index.html.erb"))
File.write(folder_path << "/index.html", templ.result)

