require 'ostruct'

class KindleRedux
	module Panels
		module Base

			def dimensions(dimensions)
				@dimensions = dimensions
				self
			end

			def read_asset(type, filename)
				asset_path = case type.to_s
				when 'template'
					KindleRedux::PANEL_DIR
				when 'css'
					KindleRedux::CSS_DIR
				else
					raise "`type` must be 'template' or 'css'"
				end

				file_path = asset_path.join filename
				raise "Can't find #{type} file: #{filename}" unless file_path.exist?
				file_path.read
			end

			def asset_from_const(const_name, type)
				if self.class.const_defined? const_name
					read_asset type, self.class.const_get(const_name)
				else
					nil
				end
			end

			def get_template
				asset_from_const(:TEMPLATE_FILENAME, 'template') or
					raise NotImplementedError, "TEMPLATE_FILENAME or get_template needs to be defined"
			end

			def get_css
				# providing css in not mandatory
				asset_from_const(:CSS_FILENAME, 'css')
			end

			def render
				raise NotImplementedError, "#{self.class} has not defined a render method"
			end

			def render_template(parameters={})
				template = ERB.new(get_template)
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
