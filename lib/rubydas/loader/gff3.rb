#
# = rubydas/loader/gff3.rb - GFF loader class
#
# Copyright:: Copyright (C) 2012
#             Alex Kalderimis <alex@intermine.org>
#

require "rubygems"
require "bio"
require "rubydas/model/feature"

module RubyDAS
    module Loader
        class GFF3

            attr_reader :gff

            def initialize fname
                @types = Hash[]
                @segments = Hash[]
                @fname = fname
            end

            def store
                gff = Bio::GFF::GFF3.new(File.open(@fname))
                puts "storing #{@fname}"
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

                    #puts args[:feature_type].label

                    args[:label] = rec.get_attribute("Name")
                    args[:public_id] = rec.get_attribute("ID")

                    if args[:feature_type].label == "mRNA"
                        args[:parent] = nil
                    else
                        args[:parent] = rec.get_attribute("Parent")
                    end

                    args[:start] = rec.start
                    args[:end] = rec.end
                    args[:score] = rec.score
                    args[:method] = rec.source
                    args[:orientation] = rec.strand
                    if rec.get_attribute("description")
                        args[:notes] = rec.get_attribute("description").split(",").map {|n| {:text => n}}
                    end

                    Feature.make(args)
                    #print "."
                    STDOUT.flush
                end
            end
        end
    end
end




