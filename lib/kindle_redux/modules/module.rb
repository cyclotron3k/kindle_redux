class KindleRedux
	module Modules
		module Module

			def dimensions(dimensions)
				@dimensions = dimensions
				self
			end

			def render
				raise NotImplementedError, "#{self.class} has not defined a render method"
			end

			def canvas
				@canvas ||= Victor::SVG.new(:width => @dimensions[:width], :height => @dimensions[:height])
			end

		end
	end
end
