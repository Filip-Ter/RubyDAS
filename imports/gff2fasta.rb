#!/usr/bin/env ruby2.1

=begin
    Only extracts FASTA from the bottom of a GFF file
=end

if ARGV.length != 2
    puts "Usage gff2fasta <gff_file> <fasta_file> #JUST FILES NO PATHS"
end

gffname = File.expand_path('../data/gff3/' + ARGV[0])
fastaname = File.expand_path('../data/fasta/' + ARGV[1])

gff = File.open(gffname, "r")
fasta = File.open(fastaname, "w")

lines = ""

reached = false
gff.each_line do |line|
    if !reached && line.chomp == "##FASTA"
        reached = true
        next
    end
    if reached
        fasta.write(line)
    end
end



 