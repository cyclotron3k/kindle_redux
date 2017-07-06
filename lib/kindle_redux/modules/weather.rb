require 'open-uri'
require 'nokogiri'
require 'base64'

class KindleRedux::Modules::Weather
	include KindleRedux::Modules::Module

	def initialize
		@url = 'ftp://ftp.bom.gov.au/anon/gen/fwo/IDN11060.xml'
		@day_icons = [
			nil,
			'anbileru_adaleru/217714_sun.svg',               # 'Sunny',
			'anbileru_adaleru/217714_sun.svg',               # 'Clear',
			'anbileru_adaleru/217568_cloudy-day.svg',        # 'Partly cloudy',
			'anbileru_adaleru/217644_clouds.svg',            # 'Cloudy',
			nil,
			'anbileru_adaleru/217621_foggy-day.svg',         # 'Hazy',
			nil,
			'anbileru_adaleru/217492_rainfall.svg',          # 'Light rain',
			'anbileru_adaleru/451080_wind-vane.svg',         # 'Windy',
			'anbileru_adaleru/217621_foggy-day.svg',         # 'Fog',
			'anbileru_adaleru/217492_rainfall.svg',          # 'Shower',
			'anbileru_adaleru/217700_rainfall.svg',          # 'Rain',
			'anbileru_adaleru/217621_foggy-day.svg',         # 'Dusty',
			'anbileru_adaleru/217494_frost.svg',             # 'Frost',
			'anbileru_adaleru/217572_snowfall.svg',          # 'Snow',
			'anbileru_adaleru/217543_storm.svg',             # 'Storm',
			'anbileru_adaleru/217492_rainfall.svg',          # 'Light shower',
		]
		@night_icons = [
			nil,
			'anbileru_adaleru/217714_sun.svg',               # 'Sunny',
			'anbileru_adaleru/217697_night.svg',             # 'Clear',
			'anbileru_adaleru/217644_clouds.svg',            # 'Partly cloudy',
			'anbileru_adaleru/217495_sky.svg',               # 'Cloudy',
			nil,
			'anbileru_adaleru/217506_foggy-night.svg',       # 'Hazy',
			nil,
			'anbileru_adaleru/217527_rainfall-at-night.svg', # 'Light rain',
			'anbileru_adaleru/451080_wind-vane.svg',         # 'Windy',
			'anbileru_adaleru/217506_foggy-night.svg',       # 'Fog',
			'anbileru_adaleru/217527_rainfall-at-night.svg', # 'Shower',
			'anbileru_adaleru/217518_drizzle.svg',           # 'Rain',
			'anbileru_adaleru/217506_foggy-night.svg',       # 'Dusty',
			'anbileru_adaleru/217493_frost.svg',             # 'Frost',
			'anbileru_adaleru/217581_snow.svg',              # 'Snow',
			'anbileru_adaleru/217544_storm-at-night.svg',    # 'Storm',
			'anbileru_adaleru/217527_rainfall-at-night.svg', # 'Light shower',
		]
	end


	def render
		data = get_data
		pp data
		if data.first[:icon]
			icon_path = KindleRedux::ASSET_DIR.join data.first[:icon]
			encoded_image = 'data:image/svg+xml;base64,' + Base64.strict_encode64(File.read icon_path)
			canvas.image 'xlink:href' => encoded_image, x: 10, y: 10, height: 100, width: 100, preserveAspectRatio: "xMidYMid"
		end
		canvas.text "#{data.first[:precis]}", x: '50%', y: 118, font_size: 12, font_family: 'arial', text_anchor: "middle"

		3.times do |i|
			icon_path = KindleRedux::ASSET_DIR.join data[i + 1][:icon]
			encoded_image = 'data:image/svg+xml;base64,' + Base64.strict_encode64(File.read icon_path)
			canvas.image 'xlink:href' => encoded_image, x: "#{33*i}%", y: 130, height: 33, width: 33, preserveAspectRatio: "xMidYMid"
		end

		canvas.render
	end

	private

	def get_data
		doc = Nokogiri::XML open(@url)
		doc.at_css('area[aac="NSW_PT132"]').css('forecast-period').map do |forecast|
			min, max = ['min', 'max'].map { |type| forecast.at_css("element[type=\"air_temperature_#{type}imum\"]") }.map { |x| x.nil? ? ?? : x.text }
			{
				icon: @day_icons[forecast.at_css('element[type="forecast_icon_code"]').text.to_i],
				precis: forecast.at_css('text[type="precis"]').text,
				rain: forecast.at_css('text[type="probability_of_precipitation"]').text,
				min_temp: min,
				max_temp: max,
			}
		end
	end
end
