#!/usr/bin/env ruby

require 'google/apis/calendar_v3'
require 'googleauth'

APPLICATION_NAME = 'GOOGLE_CALENDAR_EXAMPLE'
MY_CALENDAR_ID = 'YOUR_CALENDAR_ID@group.calendar.google.com'
CLIENT_SECRET_PATH = './client_secret.json'

class GoogleCalendar
  def initialize
    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.client_options.application_name = APPLICATION_NAME
    @service.authorization = authorize
    @calendar_id = MY_CALENDAR_ID
  end

  def authorize
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(CLIENT_SECRET_PATH),
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR)
    authorizer.fetch_access_token!
    authorizer
  end

  def get_upcoming_events(calendar_id, max_results = 256)
    response = @service.list_events(calendar_id,
                                    max_results: max_results,
                                    single_events: true,
                                    order_by: 'startTime',
                                    time_min: Time.now.iso8601)
    response.items
  end

  def show_upcoming_events(calendar_id)
    events = get_upcoming_events(calendar_id, 10)
    puts "Upcoming events:"
    puts "No upcoming events found" if events.empty?
    events.each do |event|
      start = event.start.date_time || event.start.date
      puts "  #{event.summary} (#{start})"
    end
  end

  def insert_event(start_time, end_time, summary, description, location)
    event = Google::Apis::CalendarV3::Event.new({
      summary: summary,
      description: description,
      location: location,
      start: { date_time: start_time },
      end: { date_time: end_time }
    })
    @service.insert_event(@calendar_id, event)
  end
end

calendar = GoogleCalendar.new
calendar.show_upcoming_events('ja.japanese#holiday@group.v.calendar.google.com')
