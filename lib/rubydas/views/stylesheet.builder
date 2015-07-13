xml.instruct! :xml, :version => "1.0", :standalone => "yes"
xml.DASSTYLE do 
	xml.STYLESHEET do 
		xml.CATEGORY :id => "default" do
			
			@afra_colors.each do |type_label, color|
				xml.TYPE :id => type_label do
					xml.GLYPH do
						xml.BOX do
							xml.HEIGHT "11"
							xml.FGCOLOR "black"
							xml.BGCOLOR color
							xml.BUMP "yes"
							xml.LABEL "yes"
						end
					end
				end
			end

		end
	end
end