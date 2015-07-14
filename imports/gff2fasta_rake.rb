gffname = File.expand_path('../' + ARGV[0])
fastaname = gffname.chomp(".gff").concat(".fasta")

gff = File.open(gffname, "r")
fasta = File.open(fastaname, "w")

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


