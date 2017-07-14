require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

class KindleRedux::Panels::GoogleCalendar
	include KindleRedux::Panels::Base

	TEMPLATE_FILENAME = 'events.erb'

	OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
	APPLICATION_NAME = 'kindle-redux-client-id'
	CLIENT_SECRETS_PATH = 'client_secret.json'
	CREDENTIALS_PATH = File.join(Dir.home, '.credentials', "calendar-ruby-quickstart.yaml")
	SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

	private

	def authorize
		FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

		client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
		token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
		authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
		user_id = 'default'
		credentials = authorizer.get_credentials(user_id)

		if credentials.nil?
			url = authorizer.get_authorization_url(base_url: OOB_URI)
			puts "Open the following URL in the browser and enter the resulting code after authorization"
			puts url
			code = gets
			credentials = authorizer.get_and_store_credentials_from_code(user_id: user_id, code: code, base_url: OOB_URI)
		end

		credentials
	end

	def service
		return @service if @service
		@service = Google::Apis::CalendarV3::CalendarService.new
		@service.client_options.application_name = APPLICATION_NAME
		@service.authorization = authorize
		@service
	end

	def get_calendar(calendar_name)
		calendar_id = service.list_calendar_lists.items.find do |cal|
			cal.summary_override == calendar_name or cal.summary == calendar_name
		end.id

		service.list_events(
			calendar_id,
			max_results: 10,
			single_events: true,
			order_by: 'startTime',
			time_min: Time.now.iso8601
		).items
	end

end
