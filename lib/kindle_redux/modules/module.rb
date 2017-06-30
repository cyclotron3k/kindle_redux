class KindleRedux
	module Modules
		module Module

			def dimensions(dimensions)
				@dimensions = dimensions
				self
			end

			def render(canvas)
				raise NotImplementedError, "#{self.class} has not defined a render method"
			end
		end
	end
end
