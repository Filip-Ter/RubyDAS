xml.instruct! :xml, :version => "1.0", :standalone => "yes"
xml.DASSTYLE do 
	xml.STYLESHEET do 
		xml.CATEGORY :id => "default" do
			
			used_types.each do |type, annotations|
				xml.TYPE :id => type do
					xml.GLYPH do

					if annotations[0] == "box"
						xml.BOX do
							xml.HEIGHT "11"
							xml.FGCOLOR "black"
							xml.BGCOLOR annotations[1]
							xml.BUMP "yes"
							xml.LABEL "yes"
						end
					elsif annotations[0] == "line"
						xml.LINE do 
							xml.HEIGHT "11"
							xml.FGCOLOR "black"
							xml.BGCOLOR annotations[1]
							xml.BUMP "yes"
							xml.LABEL "yes"
						end
					else
						raise ArgumentError.new("disaster")
					end
				end
			end
		end
	end
end