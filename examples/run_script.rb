require './renderer.rb'

KindleRedux.new(
	width: 600,
	height: 800,
	panels: [
		[
			KindleRedux::Modules::Weather.new(),
			KindleRedux::Modules::Calendar.new(),
		],
		[
			KindleRedux::Modules::Birthdays.new(),
			KindleRedux::Modules::Shopping.new(),
		]
	]
).render('./output.png')
