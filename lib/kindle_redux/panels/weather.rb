require 'open-uri'
require 'nokogiri'

class KindleRedux::Panels::Weather
	include KindleRedux::Panels::Base

	TEMPLATE_FILENAME = 'weather.erb'
	CSS_FILENAME = 'weather.scss'

	def initialize
		@forecast_url = 'ftp://ftp.bom.gov.au/anon/gen/fwo/IDN11060.xml'
		@current_url  = 'ftp://ftp.bom.gov.au/anon/gen/fwo/IDN60920.xml'
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
		# @night_icons = [
		# 	nil,
		# 	'anbileru_adaleru/217714_sun.svg',               # 'Sunny',
		# 	'anbileru_adaleru/217697_night.svg',             # 'Clear',
		# 	'anbileru_adaleru/217644_clouds.svg',            # 'Partly cloudy',
		# 	'anbileru_adaleru/217495_sky.svg',               # 'Cloudy',
		# 	nil,
		# 	'anbileru_adaleru/217506_foggy-night.svg',       # 'Hazy',
		# 	nil,
		# 	'anbileru_adaleru/217527_rainfall-at-night.svg', # 'Light rain',
		# 	'anbileru_adaleru/451080_wind-vane.svg',         # 'Windy',
		# 	'anbileru_adaleru/217506_foggy-night.svg',       # 'Fog',
		# 	'anbileru_adaleru/217527_rainfall-at-night.svg', # 'Shower',
		# 	'anbileru_adaleru/217518_drizzle.svg',           # 'Rain',
		# 	'anbileru_adaleru/217506_foggy-night.svg',       # 'Dusty',
		# 	'anbileru_adaleru/217493_frost.svg',             # 'Frost',
		# 	'anbileru_adaleru/217581_snow.svg',              # 'Snow',
		# 	'anbileru_adaleru/217544_storm-at-night.svg',    # 'Storm',
		# 	'anbileru_adaleru/217527_rainfall-at-night.svg', # 'Light shower',
		# ]
	end

	def render
		render_template(days: get_data)
	end

	private

	def get_data
		forecast, current = Parallel.map([@forecast_url, @current_url], in_threads: 2) do |url|
			Nokogiri::XML open(url)
		end

		data = forecast.at_css('area[aac="NSW_PT132"]').css('forecast-period').map do |forecast|
			date = Date.parse forecast.attr('start-time-local')
			min, max = ['min', 'max'].map { |type| forecast.at_css("element[type=\"air_temperature_#{type}imum\"]") }.map { |x| x.nil? ? ?? : x.text }
			icon = @day_icons[forecast.at_css('element[type="forecast_icon_code"]').text.to_i]
			icon_path = KindleRedux::IMAGE_DIR.join icon
			{
				date: date,
				icon: icon_path,
				precis: forecast.at_css('text[type="precis"]').text,
				rain: forecast.at_css('text[type="probability_of_precipitation"]').text,
				min_temp: min,
				max_temp: max,
			}
		end

		current.at_css('observations station[bom-id="066062"]').tap do |elements|
			data.first.merge!(
				apparent_temp: elements.at_css('element[type="apparent_temp"]').text,
				air_temperature: elements.at_css('element[type="air_temperature"]').text,
				humidity: elements.at_css('element[type="rel-humidity"]').text,
			)
		end

		data
	end
end
