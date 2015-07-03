xml.instruct! :xml, :version => "1.0", :standalone => "yes"
xml.DASSTYLE do 
	xml.STYLESHEET do 
		xml.CATEGORY do
			
			xml.TYPE :id => "transcript" do
				xml.GLYPH do
					xml.BOX do 
						xml.HEIGHT "10"
						xml.FGCOLOR "black"
						xml.BGCOLOR "white"
						xml.BUMP "yes"
						xml.LABEL "yes"
					end
				end
			end

			xml.TYPE :id => "translation" do 
				xml.GLYPH do 
					xml.BOX do 
						xml.HEIGHT "10"
						xml.BGCOLOR "red"
						xml.FGCOLOR "balck"
					end
				end
			end

		end
	end
end