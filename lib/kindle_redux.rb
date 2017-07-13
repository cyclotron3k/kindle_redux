require 'kindle_redux/modules/module'
require 'kindle_redux/modules/blank'
require 'kindle_redux/modules/calendar'
require 'kindle_redux/modules/birthdays'
require 'kindle_redux/modules/shopping'
require 'kindle_redux/modules/weather'
require 'kindle_redux/modules/picture_frame'

require 'parallel'
require 'erb'
require 'cliver'

class KindleRedux

	ROOT_DIR = Pathname.new(__FILE__).join("../..")
	ASSET_DIR = ROOT_DIR.join("assets")

	def initialize(params)
		@width  = params[:width]  || 600
		@height = params[:height] || 800
		@panels = params[:panels] || []
		@layout = params[:layout] || 'foursquare.erb'
		# @rotation = :none
	end

	def render_html
		template_path = Pathname.new(KindleRedux::ASSET_DIR).join 'templates', 'layouts', @layout
		raise "Can't find layout: #{@layout}" unless template_path.exist?
		template = ERB.new(template_path.read)

		panel_data = Parallel.map(@panels.flatten(1), in_threads: 4) do |panel|
			panel.render
		end

		panel_hash = [:one, :two, :three, :four].zip(panel_data).to_h
		panel_hash.merge! width: @width, height: @height
		opts = OpenStruct.new panel_hash
		template.result(opts.instance_eval {binding})
	end

	def render(filename)
		raise "Can't find wkhtmltoimage executable" unless valid_wkhtmltoimage?

		STDERR.puts "Overwriting #{filename}" if File.exists? filename

		command = [
			'wkhtmltoimage',
			'--crop-h', '800',
			'--crop-w', '600',
			'--crop-x', '0',
			'--crop-y', '0',
			'--format', 'png',
			'--height', '800',
			'--width', '600',
			'--disable-smart-width',
			'--quiet',
			'-', # read html from STDIN
			filename
		]

		IO.popen(command, "w") do |pipe|
			pipe.print render_html
			pipe.close_write
		end

	end

	private

	def valid_wkhtmltoimage?
		@valid ||= Cliver.detect('wkhtmltoimage').nil? == false
	end

	# engine = Sass::Engine.new("#main {background-color: #0000ff}", :syntax => :scss)
	# engine.render #=> "#main { background-color: #0000ff; }\n"

end
