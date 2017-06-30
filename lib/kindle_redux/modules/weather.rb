require 'open-uri'
require 'nokogiri'

class KindleRedux::Modules::Weather
	include KindleRedux::Modules::Module

	def initialize
		@url = 'ftp://ftp.bom.gov.au/anon/gen/fwo/IDN11060.xml'
		@day_icons = [
			'', # nil,
			'', # 'Sunny',
			'', # 'Clear',
			'', # 'Partly cloudy',
			'', # 'Cloudy',
			'', # nil,
			'', # 'Hazy',
			'', # nil,
			'', # 'Light rain', # *
			'', # 'Windy', # *
			'', # 'Fog', # *
			'', # 'Shower',
			'', # 'Rain',
			'', # 'Dusty', # *
			'', # 'Frost', # *
			'', # 'Snow',
			'', # 'Storm',
			'', # 'Light shower', # *
		]
		@night_icons = [
			'', # nil,
			'', # 'Sunny',
			'', # 'Clear',
			'', # 'Partly cloudy',
			'', # 'Cloudy',
			'', # nil,
			'', # 'Hazy',
			'', # nil,
			'', # 'Light rain', # *
			'', # 'Windy', # *
			'', # 'Fog', # *
			'', # 'Shower',
			'', # 'Rain',
			'', # 'Dusty', # *
			'', # 'Frost', # *
			'', # 'Snow',
			'', # 'Storm',
			'', # 'Light shower', # *
		]
	end

	def render(canvas)
		doc = Nokogiri::XML open(@url)
		doc.at_css('area[aac="NSW_PT132"]').css('forecast-period').each do |forecast|
			puts @day_icons[forecast.at_css('element[type="forecast_icon_code"]').text.to_i]
			puts forecast.at_css('text[type="precis"]').text
			puts forecast.at_css('text[type="probability_of_precipitation"]').text
			puts ""
		end
	end
end
