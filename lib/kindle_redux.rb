require 'kindle_redux/modules/module'
require 'kindle_redux/modules/blank'
require 'kindle_redux/modules/calendar'
require 'kindle_redux/modules/birthdays'
require 'kindle_redux/modules/shopping'
require 'kindle_redux/modules/weather'
require 'kindle_redux/modules/picture_frame'

require 'parallel'
require 'victor'

class KindleRedux

	ROOT_DIR = Pathname.new(__FILE__).join("../..")
	ASSET_DIR = ROOT_DIR.join("assets")

	def initialize(params)
		@width  = params[:width]  || 600
		@height = params[:height] || 800
		@panels = params[:panels] || []
		@rotation = :none
	end

	def render(filename)
		canvas = Victor::SVG.new(:width => @width, :height => @height)

		rows = @panels.count
		@panels.each_with_index do |row, j|
			columns = row.count
			row.each_with_index do |panel, i|
				width  = 1.0 * @width  / columns
				height = 1.0 * @height / rows
				panel.dimensions(
					width:  width,
					height: height,
					# top:    (j      * height),
					# right:  (i.next * width),
					# bottom: (j.next * height),
					# left:   (i      * width),
				)
			end
		end

		svg_panels = Parallel.map(@panels.flatten(1), in_threads: 4) do |panel|
			panel.render
		end
	end

	private

	def render_svg
	end
end
