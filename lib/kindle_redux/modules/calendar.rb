require 'kindle_redux/modules/google_calendar'

class KindleRedux::Modules::Calendar < KindleRedux::Modules::GoogleCalendar

	def render
		events = get_calendar('Shared').map do |event|
			start = event.start.date || event.start.date_time
			[event.summary, start]
		end
		render_template('events.erb', events: events, title: "Upcoming events", empty_text: "No upcoming events")
	end

end
