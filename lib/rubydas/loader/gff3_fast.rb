require "rubygems"
require "bio"
require "rubydas/model/feature"

module RubyDAS
    module Loader
        module FMT
            FEATURES = "INSERT INTO FEATURES VALUES (%s);"
            FEATURE_TYPES = "INSERT OR IGNORE INTO FEATURE_TYPES VALUES (%s);"
            SEGMENTS = "INSERT OR IGNORE INTO SEGMENTS VALUES (%s);"
            NOTES = "INSERT INTO NOTES VALUES (%s);"
            TARGETS = "INSERT INTO TARGETS VALUES (%s);"
            LINKS = "INSERT INTO LINKS VALUES (%s);"


            def fmt(s)

                if s == nil
                    return "NULL"
                elsif s.class == String
                    return "\"#{s}\""
                else
                    return s
                end
            end
        end


        class GFF3Fast
            include FMT
        	#cols: # id, public_id, label, parent, start, end, method, score, phase, orientation, feature_type_id, segment_id
        	#@@feature_insert = "INSERT INTO FEATURES VALUES (%d, %s, %s, %s, %d, %d, %s, %f, %d, %d, %d, %d);"
            #@@sequence

            def initialize fname
                @types = Hash[]
                @segments = Hash[]
                @fname = fname

                ##CREATES
            end


            def store
                gff = Bio::GFF::GFF3.new(File.open(@fname))
                puts "storing #{fmt @fname}"
                gff.records.each_with_index do |rec, i|
                    args = Hash.new

                    if @types.has_key? rec.feature
                        args[:feature_type] = @types[rec.feature]
                    else 
                        args[:feature_type] = @types[rec.feature] = FeatureType.create(:label => rec.feature)
                    end

                    if @segments.has_key? rec.seqname
                        args[:segment] = @segments[rec.seqname]
                    else 
                        args[:segment] = @segments[rec.seqname] = Segment.create(:public_id => rec.seqname, :label => rec.feature)
                    end

                    #puts args[:feature_type].label

                    args[:label] = rec.get_attribute("Name")
                    args[:public_id] = rec.get_attribute("ID")

                    if args[:feature_type].label == "mRNA" || args[:feature_type].label == "transcript"
                        args[:parent] = nil
                    else
                        args[:parent] = rec.get_attribute("Parent")
                    end
 
                    if rec.get_attribute("description")
                        args[:notes] = rec.get_attribute("description").split(",").map {|n| {:text => n}}
                    end

                    db_adapter = DataMapper.repository(:default).adapter 

                    db_adapter.execute(FEATURES % "#{fmt i}, #{fmt args[:public_id]}, #{fmt args[:label]}, #{fmt args[:parent]}, " \
                                                   "#{fmt rec.start}, #{fmt rec.end}, #{fmt rec.source}, #{fmt rec.score}, " \
                                                   "#{fmt args[:phase]}, #{fmt rec.strand}, #{fmt args[:feature_type].id}, " \
                                                   "#{fmt args[:segment].id}")

                    db_adapter.execute(FEATURE_TYPES % "#{fmt args[:feature_type].id}, #{fmt args[:feature_type].category}, " \
                                                        "#{fmt args[:feature_type].reference}, #{fmt args[:feature_type].label}")

                    db_adapter.execute(SEGMENTS % "#{fmt args[:segment].id}, #{fmt args[:segment].public_id}, " \
                                                   "#{fmt args[:segment].segment_type}, #{fmt args[:segment].label}")

                end
            end
        end
    end
end
