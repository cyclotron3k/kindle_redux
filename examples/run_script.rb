require 'kindle_redux'

KindleRedux.new(
	width: 600,
	height: 800,
	layout: 'foursquare.erb',
	panels: [
		KindleRedux::Modules::Weather.new(),
		KindleRedux::Modules::Calendar.new(),
		KindleRedux::Modules::Birthdays.new(),
		KindleRedux::Modules::Shopping.new(),
	],
).render('/full/path/output.png')
