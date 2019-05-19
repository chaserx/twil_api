require 'json'
require 'httparty'
require 'chronic'
require 'date'
require 'erb'

def lambda_handler(event:, context:)
  {
    statusCode: 200,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Credentials": "true",
      "Content-Type": "text/html"
    },
    body: render
  }
end

def this_monday
  Chronic.parse('monday this week').strftime("%Y-%m-%d")
end

def this_sunday
  Chronic.parse('sunday this week').strftime("%Y-%m-%d")
end

def fetch_this_week
  response = HTTParty.get("https://www.lexingtonky.gov/calendar/fetchEvents?start=#{this_monday}&end=#{this_sunday}")
  # puts response.inspect
  response
rescue HTTParty::Error => error
  puts error.inspect
  raise error
end

def format_calendar(calendar_data)
  events = JSON.parse(calendar_data)
  @week = Week.new
  @week.monday = events.select{|ev| DateTime.parse(ev.fetch("start")).monday?}
  @week.tuesday = events.select{|ev| DateTime.parse(ev.fetch("start")).tuesday?}
  @week.wednesday = events.select{|ev| DateTime.parse(ev.fetch("start")).wednesday?}
  @week.thursday = events.select{|ev| DateTime.parse(ev.fetch("start")).thursday?}
  @week.friday = events.select{|ev| DateTime.parse(ev.fetch("start")).friday?}
  @week.saturday = events.select{|ev| DateTime.parse(ev.fetch("start")).saturday?}
  @week.sunday = events.select{|ev| DateTime.parse(ev.fetch("start")).sunday?}
  puts @week.inspect
  @week
end

def build
  ERB.new(skeleton, 0, "<>")
end

def render
  build.result(binding)
end

def skeleton
  @week = format_calendar(fetch_this_week.body)
  %q{
  <html>
    <body>
      <h1>This Week in LFUCG</h1>
      <h2>Start date: <%= this_monday %> - Stop date: <%= this_sunday %> </h2>
      <div>
        <h3>MONDAY</h3>
        <ul>
          <% @week.monday.each do |mon| %>
            <li><a href="https://www.lexingtonky.gov<%= mon.fetch("url") %>"><%= mon.fetch("title") %></a></li>
          <% end %>
        </ul>

        <h3>TUESDAY</h3>
        <ul>
          <% @week.tuesday.each do |tue| %>
            <li><a href="https://www.lexingtonky.gov<%= tue.fetch("url") %>"><%= tue.fetch("title") %></a></li>
          <% end %>
        </ul>

        <h3>WEDNESDAY</h3>
        <ul>
          <% @week.wednesday.each do |wed| %>
            <li><a href="https://www.lexingtonky.gov<%= wed.fetch("url") %>"><%= wed.fetch("title") %></a></li>
          <% end %>
        </ul>

        <h3>THURSDAY</h3>
        <ul>
          <% @week.thursday.each do |thurs| %>
            <li><a href="https://www.lexingtonky.gov<%= thurs.fetch("url") %>"><%= thurs.fetch("title") %></a></li>
          <% end %>
        </ul>

        <h3>FRIDAY</h3>
        <ul>
          <% @week.friday.each do |fri| %>
            <li><a href="https://www.lexingtonky.gov<%= fri.fetch("url") %>"><%= fri.fetch("title") %></a></li>
          <% end %>
        </ul>

        <h3>SATURDAY</h3>
        <ul>
          <% @week.saturday.each do |sat| %>
            <li><a href="https://www.lexingtonky.gov<%= sat.fetch("url") %>"><%= sat.fetch("title") %></a></li>
          <% end %>
        </ul>

        <h3>SUNDAY</h3>
        <ul>
          <% @week.sunday.each do |sun| %>
            <li><a href="https://www.lexingtonky.gov<%= sun.fetch("url") %>"><%= sun.fetch("title") %></a></li>
          <% end %>
        </ul>
      </div>

      <p><small>This site is not afiliated with LFUCG. Calendar data reformatted from an official source. Use at your own risk.</small></p>
    </body>
  </html>
  }.gsub(/^  /, '')
end

class Week
  attr_accessor :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday
  def initialize
    @monday = []
    @tuesday = []
    @wednesday = []
    @thursday = []
    @friday = []
    @saturday = []
    @sunday = []
  end
end
