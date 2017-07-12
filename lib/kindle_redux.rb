require 'kindle_redux/modules/module'
require 'kindle_redux/modules/blank'
require 'kindle_redux/modules/calendar'
require 'kindle_redux/modules/birthdays'
require 'kindle_redux/modules/shopping'
require 'kindle_redux/modules/weather'
require 'kindle_redux/modules/picture_frame'

require 'parallel'
require 'erb'


class KindleRedux

	ROOT_DIR = Pathname.new(__FILE__).join("../..")
	ASSET_DIR = ROOT_DIR.join("assets")

	def initialize(params)
		@width  = params[:width]  || 600
		@height = params[:height] || 800
		@panels = params[:panels] || []
		@rotation = :none
	end

	def render
		template_path = KindleRedux::ASSET_DIR.join 'templates', 'foursquare.erb'
		template = File.read template_path

		panel_data = Parallel.map(@panels.flatten(1), in_threads: 4) do |panel|
			panel.render
		end

		panel_hash = [:one, :two, :three, :four].zip(panel_data).to_h

		puts ERB.new(template).result_with_hash(panel_hash)
	end

	private

	def render_svg
	end
end
