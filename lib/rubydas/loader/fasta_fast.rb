require "rubygems"
require "bio"
require "rubydas/model/sequence"

module RubyDAS
    module Loader

        module FMT
            SEQUENCE = "INSERT INTO SEQUENCES VALUES (%s);" 
            SEQUENCE_FRAGMENT = "INSERT OR IGNORE INTO SEQUENCE_FRAGMENTS VALUES (%s);"
        end

        class FASTAFast
            include FMT

            def initialize filename
                @filename = filename
            end

            def store
                puts "Storing #{@filename}"
                ff = Bio::FlatFile.open(Bio::FastaFormat, @filename)
                db_adapter = DataMapper.repository(:default).adapter 

                ff.each_with_index do |entry, i|
                      s = Sequence.new(
                       :public_id => entry.entry_id,
                        :length => entry.length,
                        :label => entry.entry_id
                     )
                      
                    db_adapter.execute(SEQUENCE % "#{i}, #{fmt entry.entry_id}, #{fmt entry.entry_id}, "\
                                                    "NULL, NULL, " \
                                                    "#{fmt entry.length}")

                    current_seq = ""
                    pos = 0
                    j = 0
                    entry.seq.each_char do |c|
                        pos += 1
                        current_seq << c
                        if current_seq.length >= 1000 || pos >= entry.length
                            j += 1
                            db_adapter.execute(SEQUENCE_FRAGMENT % "#{j}, #{fmt current_seq}, #{fmt (pos - current_seq.length)}, "\
                                                                   "#{fmt pos}, #{i}")
 
                            current_seq = ""
                            #print "."
                            STDOUT.flush
                        end

                    end
                end

            end
        end
    end
end

