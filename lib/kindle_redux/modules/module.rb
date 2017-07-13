require 'ostruct'

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

			def render_template(template, parameters={})
				template_path = Pathname.new(KindleRedux::ASSET_DIR).join 'templates', 'panels', template
				raise "Can't find template: #{template}" unless template_path.exist?

				template = ERB.new(template_path.read)
				if template.respond_to? :result_with_hash
					# only available in Ruby >= 2.5
					template.result_with_hash parameters
				else
					opts = OpenStruct.new parameters
					template.result(opts.instance_eval {binding})
				end
			end
		end
	end
end
