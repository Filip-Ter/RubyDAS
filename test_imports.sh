#!/bin/sh

cd imports
echo "Making FASTA"
ruby gff2fasta.rb Si_gnF.gff Si_gnF.fasta
echo "Importing GFF"
ruby import.rb Si_gnF.gff signf.db
echo "Importing FASTA"
ruby import.rb Si_gnF.fasta signf.db

cd ..
echo "Run with \"rake start\[signf.db\]\""
