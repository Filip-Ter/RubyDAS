require "rubygems"
require "bio"
require "rubydas/model/feature"

module RubyDAS
    module Loader
        module FMT
            FEATURES = "INSERT INTO FEATURES VALUES "
            FEATURE_TYPES = "INSERT OR IGNORE INTO FEATURE_TYPES VALUES "
            SEGMENTS = "INSERT OR IGNORE INTO SEGMENTS VALUES "
            NOTES = "INSERT INTO NOTES VALUES "
            TARGETS = "INSERT INTO TARGETS VALUES "
            LINKS = "INSERT INTO LINKS VALUES "

            def fmt(s)

                if s == nil
                    return "NULL"
                elsif s.class == String
                    return "\'#{s}\'"
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

            def reset
                @res_features = FEATURES.dup
                @res_feature_types = FEATURE_TYPES.dup
                @res_segments = SEGMENTS.dup
            end

            def insert(db_adapter)
                @res_features.chomp!(", ")
                @res_feature_types.chomp!(", ")
                @res_segments.chomp!(", ")
                #p @res_feature_types + "\n"

                @res_features << ";"
                @res_feature_types << ";"
                @res_segments << ";"

                db_adapter.execute(@res_feature_types)
                db_adapter.execute(@res_segments)
                db_adapter.execute(@res_features)

                #puts "storing"
                reset
            end



            def initialize fname
                @types = Hash[]
                @segments = Hash[]
                @fname = fname
                
                @res_features = "INSERT INTO FEATURES VALUES "
                @res_feature_types = "INSERT OR IGNORE INTO FEATURE_TYPES VALUES "
                @res_segments = "INSERT OR IGNORE INTO SEGMENTS VALUES " 
                ##CREATES
            end


            def store
                gff = Bio::GFF::GFF3.new(File.open(@fname))
                puts "Storing GFF #{fmt @fname}"
                db_adapter = DataMapper.repository(:default).adapter 
                
                ctr = 0
                feature_id = 0
                gff.records.each do |rec|
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

        
                    feature_id += 1
                    #puts feature_id
                    @res_features << "(#{feature_id}, #{fmt args[:public_id]}, #{fmt args[:label]}, #{fmt args[:parent]}, " \
                                                   "#{fmt rec.start}, #{fmt rec.end}, #{fmt rec.source}, #{fmt rec.score}, " \
                                                   "#{fmt args[:phase]}, #{fmt rec.strand}, #{fmt args[:feature_type].id}, " \
                                                   "#{fmt args[:segment].id}), "

                    @res_feature_types << "(#{fmt args[:feature_type].id}, #{fmt args[:feature_type].category}, " \
                                                        "#{fmt args[:feature_type].reference}, #{fmt args[:feature_type].label}), "

                    @res_segments << "(#{fmt args[:segment].id}, #{fmt args[:segment].public_id}, " \
                                                   "#{fmt args[:segment].segment_type}, #{fmt args[:segment].label}), "
                    ctr += 1
                        if ctr > 10000
                            insert(db_adapter)
                            ctr = 0
                        end
                end
                #p @res_feature_types
                insert(db_adapter)
            end
        end
    end
end
