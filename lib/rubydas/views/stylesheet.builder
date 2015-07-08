xml.instruct! :xml, :version => "1.0", :standalone => "yes"
xml.DASSTYLE do 
	xml.STYLESHEET do 
		xml.CATEGORY do
			
			@type_labels.each_with_index do |label, i|
				xml.TYPE :id => label do
					xml.GLYPH do
						xml.BOX do
							xml.HEIGHT "10"
							xml.FGCOLOR "black"
							xml.BGCOLOR @bg_colors[i]
							xml.BUMP "yes"
							xml.LABEL "yes"
						end
					end
				end
			end
			
			# xml.TYPE :id => "match" do
			# 	xml.GLYPH do
			# 		xml.BOX do 
			# 			xml.HEIGHT "10"
			# 			xml.FGCOLOR "black"
			# 			xml.BGCOLOR "white"
			# 			xml.BUMP "yes"
			# 			xml.LABEL "yes"
			# 		end
			# 	end
			# end

			# xml.TYPE :id => "match_part" do
			# 	xml.GLYPH do
			# 		xml.BOX do 
			# 			xml.HEIGHT "10"
			# 			xml.FGCOLOR "black"
			# 			xml.BGCOLOR "orange"
			# 			xml.BUMP "yes"
			# 			xml.LABEL "yes"
			# 		end
			# 	end
			# end

			# xml.TYPE :id => "exon" do
			# 	xml.GLYPH do
			# 		xml.BOX do 
			# 			xml.HEIGHT "10"
			# 			xml.FGCOLOR "black"
			# 			xml.BGCOLOR "blue"
			# 			xml.BUMP "yes"
			# 			xml.LABEL "yes"
			# 		end
			# 	end
			# end

			# xml.TYPE :id => "mRNA" do
			# 	xml.GLYPH do
			# 		xml.BOX do 
			# 			xml.HEIGHT "10"
			# 			xml.FGCOLOR "black"
			# 			xml.BGCOLOR "green"
			# 			xml.BUMP "yes"
			# 			xml.LABEL "yes"
			# 		end
			# 	end
			# end

			# xml.TYPE :id => "protein_match" do
			# 	xml.GLYPH do
			# 		xml.BOX do 
			# 			xml.HEIGHT "10"
			# 			xml.FGCOLOR "black"
			# 			xml.BGCOLOR "red"
			# 			xml.BUMP "yes"
			# 			xml.LABEL "yes"
			# 		end
			# 	end
			# end

			# xml.TYPE :id => "contig" do 
			# 	xml.GLYPH do 
			# 		xml.BOX do 
			# 			xml.HEIGHT "10"
			# 			xml.BGCOLOR "red"
			# 			xml.FGCOLOR "black"
			# 			xml.LABEL "yes"
			# 		end
			# 	end
			# end

			# xml.TYPE :id => "translated_nucleotide_match" do 
			# 	xml.GLYPH do 
			# 		xml.BOX do 
			# 			xml.HEIGHT "10"
			# 			xml.BGCOLOR "red"
			# 			xml.FGCOLOR "yellow"
			# 			xml.LABEL "yes"
			# 		end
			# 	end
			# end

		end
	end
end