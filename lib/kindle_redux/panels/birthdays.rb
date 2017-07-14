require 'kindle_redux/panels/google_calendar'

class KindleRedux::Panels::Birthdays < KindleRedux::Panels::GoogleCalendar

	CSS_FILENAME = 'birthdays.scss'

	def render
		birthdays = get_calendar('Birthdays').map do |event|
			start = Date.parse(event.start.date)
			[event.summary, start]
		end
		render_template(events: birthdays, title: "Upcoming Birthdays!", empty_text: "No upcoming birthdays")
	end

end
