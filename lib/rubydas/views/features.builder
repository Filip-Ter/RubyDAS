xml.instruct! :xml, :version => '1.0', :standalone => "yes"
xml.declare! :DOCTYPE, :DASFEATURES, :SYSTEM, "http://www.biodas.org/dtd/dasgff.dtd"
xml.DASGFF  do
  xml.GFF :version => "1.0", :href => request.url do
    if @features_hash != nil
      @features_hash.each_with_index do |(segment,features), index|
        if features != "unknown_segment"
          xml.SEGMENT :id => segment.segment_name, :version => "1.0", :start => segment.start, :stop => segment.stop do
            features.each do |feature|
              has_parent = feature.parent != nil 
              
              feature_attrs = {:id => feature.id}

              unless has_parent
                feature_attrs[:label] = feature.public_id
              end

              xml.FEATURE feature_attrs  do 
                xml.TYPE :id => feature.feature_type.label
                xml.METHOD :id => feature.method
                xml.START feature.start
                xml.END feature.end
                if feature.score != nil 
                  xml.SCORE feature.score 
                end
                if feature.orientation != nil
                  xml.ORIENTATION feature.orientation
                end
                if feature.phase != nil
                  xml.PHASE feature.phase
                end
                feature.notes.each do |n|
                  xml.NOTE n.text
                end
                feature.links.each do |l| 
                  xml.LINK(l.text, :href => l.href)
                end
                
                if has_parent
                  xml.GROUP :id => feature.parent
                else 
                  xml.GROUP :id => feature.public_id
                end

              end 
            end
          end
        else
          xml.UNKOWNSEGMENT :id => segment.segment_name
        end
      end
    end
  end
end
