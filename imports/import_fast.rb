$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require "rubygems"
require "rubydas/loader/gff3_fast"
require "rubydas/loader/fasta_fast"

def usage
	puts "#{ARGV[0]} #{ARGV[1]} #{ARGV[2]}"
	puts "Usage test_gff_load.rb <filename> <database> (optional)--rewrite #JUST NAMES NO PATHS"
	exit
end

if ARGV.length != 2 && ARGV.length != 3
   usage 
end

rewrite = false

if ARGV.length == 3
	if ["", "-", "--"].each {|s| s << "rewrite"}.include? ARGV[2]
		rewrite = true
	else 
		usage
	end
end


type = ARGV[0].split(".")[1].chomp

if type != "fasta" && type != "gff" && type != "gff3"
	puts "only gff or fasta"
	puts type
	exit
elsif type == "gff"
	type << "3"
end

db_path = 'sqlite://' + File.expand_path("../" << ARGV[1])
file_path = File.expand_path("../" << ARGV[0])

DataMapper.setup(:default, db_path)

puts "CREATING DB"

#unless rewrite
	DataMapper.auto_upgrade!
#else
	DataMapper.auto_migrate!
#end

loader = (type == "gff3") ? RubyDAS::Loader::GFF3Fast.new(file_path) :  RubyDAS::Loader::FASTAFast.new(file_path)
loader.store
