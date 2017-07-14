require 'kindle_redux/panels/google_calendar'

class KindleRedux::Panels::Calendar < KindleRedux::Panels::GoogleCalendar

	def render
		events = get_calendar('Shared').map do |event|
			start = event.start.date || event.start.date_time
			[event.summary, start]
		end
		render_template(events: events, title: "Upcoming events", empty_text: "No upcoming events")
	end

end
