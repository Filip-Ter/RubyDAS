require "rubygems"
require "bio"
require "rubydas/model/sequence"

module RubyDAS
    module Loader

        module FMT
            SEQUENCE = "INSERT INTO SEQUENCES VALUES " 
            SEQUENCE_FRAGMENT = "INSERT OR IGNORE INTO SEQUENCE_FRAGMENTS VALUES "
        end

        class FASTAFast
            include FMT

            def initialize filename
                @filename = filename
                reset
            end

            def reset
                @res_sequences = SEQUENCE.dup
                @res_sequence_fragment = SEQUENCE_FRAGMENT.dup
            end

            def insert_seq(adapter)
                @res_sequences.chomp!(", ")
                @res_sequence_fragment.chomp!(", ")

                @res_sequences << ";"
                @res_sequence_fragment << ";"

                puts @res_sequences
                adapter.execute(@res_sequences)
                adapter.execute(@res_sequence_fragment)
            end

            def process(adapter, line)
                line.chomp!(", ")
                line << ";"
                adapter.execute line
            end


            def store
                puts "Storing FASTA #{@filename}"
                ff = Bio::FlatFile.open(Bio::FastaFormat, @filename)
                db_adapter = DataMapper.repository(:default).adapter 

                ff.each_with_index do |entry, i|

                    @res_sequences << "(#{i}, #{fmt entry.entry_id}, #{fmt entry.entry_id}, " \
                                                    "NULL, NULL, " \
                                                    "#{fmt entry.length}), "
                        
                    current_seq = ""
                    pos = 0
                    j = 0
                    ctr = 0
                    entry.seq.each_char do |c|
                        pos += 1
                        ctr += 1
                        current_seq << c
                        if current_seq.length >= 1000 || pos >= entry.length
                            j += 1
                            @res_sequence_fragment << "(#{j}, #{fmt current_seq}, #{fmt(pos - current_seq.length)}, " \
                                                       "#{fmt pos}, #{i}), "
 
                            current_seq = ""
                            #STDOUT.flush
                        end

                        if ctr > 10000
                            process db_adapter, @res_sequence_fragment
                            @res_sequence_fragment = SEQUENCE_FRAGMENT.dup
                            ctr = 0
                        end

                    end
                    
                    unless ctr == 0
                        process db_adapter, @res_sequence_fragment
                        @res_sequence_fragment = SEQUENCE_FRAGMENT.dup
                    end
                end

                process db_adapter, @res_sequences
            end
        end
    end
end

