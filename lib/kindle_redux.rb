require 'kindle_redux/panels/base'
require 'kindle_redux/panels/blank'
require 'kindle_redux/panels/calendar'
require 'kindle_redux/panels/birthdays'
require 'kindle_redux/panels/shopping'
require 'kindle_redux/panels/weather'
require 'kindle_redux/panels/picture_frame'

require 'parallel'
require 'erb'
require 'cliver'
require 'sass'

class KindleRedux

	ROOT_DIR   = Pathname.new(__FILE__).join("../..")
	ASSET_DIR  = ROOT_DIR.join("assets")
	IMAGE_DIR  = ASSET_DIR.join("images")
	LAYOUT_DIR = ASSET_DIR.join("templates", "layouts")
	PANEL_DIR  = ASSET_DIR.join("templates", "panels")
	CSS_DIR    = ASSET_DIR.join("templates", "css")

	def initialize(params)
		@width  = params[:width]  || 600
		@height = params[:height] || 800
		@panels = params[:panels] || []
		@layout = params[:layout] || 'foursquare.erb'
		# @rotation = :none
	end

	def render_html
		template_path = LAYOUT_DIR.join @layout
		raise "Can't find layout: #{@layout}" unless template_path.exist?
		template = ERB.new(template_path.read)

		panel_data = Parallel.map(@panels.flatten(1), in_threads: 4) do |panel|
			[panel.get_css, panel.render]
		end

		css = panel_data.map(&:first).compact.map do |css_fragment|
			engine = Sass::Engine.new(css_fragment, :syntax => :scss)
			engine.render
		end.join "\n"

		panel_hash = [:one, :two, :three, :four].zip(panel_data.map &:last).to_h
		panel_hash.merge! width: @width, height: @height, css: css
		opts = OpenStruct.new panel_hash
		template.result(opts.instance_eval {binding})
	end

	def render(filename)
		raise "Can't find wkhtmltoimage executable" unless valid_wkhtmltoimage?

		STDERR.puts "Overwriting #{filename}" if File.exists? filename

		command = [
			'wkhtmltoimage',
			'--crop-h', @height.to_s,
			'--crop-w', @width.to_s,
			'--crop-x', '0',
			'--crop-y', '0',
			'--format', 'png',
			'--height', @height.to_s,
			'--width',  @width.to_s,
			'--disable-smart-width',
			'--disable-local-file-access',
			'--allow', ASSET_DIR.to_s,
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
		@valid_wkhtmltoimage ||= Cliver.detect('wkhtmltoimage').nil? == false
	end

end
