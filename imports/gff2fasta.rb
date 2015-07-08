#!/usr/bin/env ruby2.1

=begin
    Only extracts FASTA from the bottom of a GFF file
=end

if ARGV.length != 2
    puts "Usage gff2fasta <gff_file> <fasta_file> #JUST FILES NO PATHS"
end

gffname = File.expand_path('gff3/' + ARGV[0])
fastaname = File.expand_path('fasta/' + ARGV[1])

gff = File.open(gffname, "r")
fasta = File.open(fastaname, "w")

lines = ""

reached = false
counter = 0
gff.each_line do |line|
    if !reached && line.chomp == "##FASTA"
        reached = true
        next
    end
    if reached
        if counter < 1000
            lines << line
            counter += 1
        else
            fasta.write(lines)
            lines = ""
            counter = 0
        end
    end
end








