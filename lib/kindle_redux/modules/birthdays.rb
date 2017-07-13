require 'kindle_redux/modules/google_calendar'

class KindleRedux::Modules::Birthdays < KindleRedux::Modules::GoogleCalendar

	def render
		birthdays = get_calendar('Birthdays').map do |event|
			start = event.start.date || event.start.date_time
			[event.summary, start]
		end
		render_template('events.erb', events: birthdays, title: "Upcoming Birthdays!", empty_text: "No upcoming birthdays")
	end

end
