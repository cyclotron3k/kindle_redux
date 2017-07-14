require 'kindle_redux'

KindleRedux.new(
	width: 600,
	height: 800,
	layout: 'foursquare.erb',
	panels: [
		KindleRedux::Panels::Weather.new(),
		KindleRedux::Panels::Calendar.new(),
		KindleRedux::Panels::Birthdays.new(),
		KindleRedux::Panels::Shopping.new(),
	],
).render('/full/path/output.png')
