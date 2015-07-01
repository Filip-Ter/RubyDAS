$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require "rubygems"
require "rubydas/loader/gff3"

DB_PREFIX = 'sqlite://' + File.expand_path('../data') + '/'
GFF_PREFIX = File.expand_path('./gff3') + '/'

if ARGV.length != 2
    puts "Usage test_gff_load.rb <gff> <database>"
end

db_path = DB_PREFIX + ARGV[1]
gff_path = GFF_PREFIX + ARGV[0]


DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, db_path)

puts "CREATING DB"
DataMapper.auto_migrate!

loader = RubyDAS::Loader::GFF3.new(gff_path)
loader.store
#loader.gff.records.each do |r| 
#    name = r.get_attribute("Name")
#    ident = r.get_attribute("ID")
#    puts "#{(name || ident)} (#{r.feature}) #{r.seqname}:#{r.start}..#{r.end} #{r.strand}"
#end
#

fs = Feature.all 

puts fs.size

fs.each do |f|
    puts f
end

sgs = Segment.all

puts sgs.size

sgs.each do |s|
    puts "#{s.label}: #{s.features.size} features"
end




