require 'kindle_redux/modules/module'
require 'kindle_redux/modules/blank'
require 'kindle_redux/modules/calendar'
require 'kindle_redux/modules/birthdays'
require 'kindle_redux/modules/shopping'
require 'kindle_redux/modules/weather'

require 'parallel'

class KindleRedux

	def initialize(params)
		@width  = params[:width]  || 600
		@height = params[:height] || 800
		@panels = params[:panels] || []
	end

	def render(filename)
		canvas = [] # SVG.new

		rows = @panels.count
		@panels.each_with_index do |row, j|
			columns = row.count
			row.each_with_index do |panel, i|
				width  = 1.0 * @width  / columns
				height = 1.0 * @height / rows
				panel.dimensions(
					width:  width,
					height: height,
					top:    (j      * height),
					right:  (i.next * width),
					bottom: (j.next * height),
					left:   (i      * width),
				)
			end
		end

		Parallel.each(@panels.flatten(1), in_threads: 4) do |panel|
			panel.render(canvas)
		end
	end

	private

	def render_svg
	end
end
