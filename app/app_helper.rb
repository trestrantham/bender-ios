module AppHelper
  module_function

  def parse_date_string(date_string, input_format = "yyyy-MM-dd HH:mm:ss z", output_format = nil)
    date_formatter = NSDateFormatter.alloc.init
    date_formatter.dateFormat = input_format
    date = date_formatter.dateFromString date_string

    if output_format
      date_formatter.dateFormat = output_format
      date = date_formatter.stringFromDate date
    end

    date
  end

  def current_user
    App::Persistence[:current_user]
  end

  def current_user=(user)
    App::Persistence[:current_user] = user
  end

  def valid_url?(url = "")
    candidate_url = NSURL.URLWithString(url)
    candidate_url && candidate_url.scheme && candidate_url.host ? true : false
  end

  def parse_api(http_verb = :get, request = "", options = {}, &block)
    if ![:get, :post, :put, :delete, :head, :patch].include? http_verb
      puts "!!! AppHelper > parse_api > INVALID http_verb"
      return
    end

    # Ensure our request leads with "/"
    request.insert(0, "/") if request[0].to_s != "/"

    if App::Persistence[:api_url].blank?
      App.alert("API URL is required!")
      return 
    end

    if !AppHelper.valid_url?(App::Persistence[:api_url])
      App.alert("Invalid URL.")
      return
    end

    BW::HTTP.send(http_verb, "#{App::Persistence[:api_url]}#{request}", options) do |response|
      if response.ok?
        block.call(response) if block
      else
        App.alert("Server cannot be reached.")
      end
    end
  end
end

class NSDictionary
  def symbolize_keys
    dup.symbolize_keys!
  end

  def symbolize_keys!
    replace(Hash[self.map{|(k,v)| [k.to_sym,v]}])
  end
end

# For ShadowView
class NSArray
  def to_pointer(type)
    ptr = Pointer.new(type, self.size)
    self.each_with_index {|value, idx| ptr[idx] = value }
    ptr
  end
end

class NSDate
  SECOND = 1
  MINUTE = 60 * SECOND
  HOUR = 60 * MINUTE
  DAY = 24 * HOUR
  MONTH = 30 * DAY
 
  def relative_date_string
    now = NSDate.date
    delta = self.timeIntervalSinceDate(now) * -1

    calendar = NSCalendar.currentCalendar
    units = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
    components = calendar.components(units, fromDate: self, toDate: now, options: 0)

    relative_string = ""

    if delta < 0
        relative_string = "!n the future!"
    elsif delta < 1 * MINUTE
        relative_string = components.second == 1 ? "One second ago" : "#{components.second} seconds ago"
    elsif delta < 2 * MINUTE
        relative_string = "a minute ago"
    elsif delta < 45 * MINUTE
        relative_string = "#{components.minute} minutes ago"
    elsif delta < 90 * MINUTE
        relative_string = "an hour ago"
    elsif delta < 24 * HOUR
        relative_string = "#{components.hour} hours ago"
    elsif delta < 48 * HOUR
        relative_string = "yesterday"
    elsif delta < 30 * DAY
        relative_string = "#{components.day} days ago"
    elsif delta < 12 * MONTH
        relative_string = components.month <= 1 ? "one month ago" : "#{components.month} months ago"
    else
        relative_string = components.year <= 1 ? "one year ago" : "#{components.year} years ago"
    end

    return relative_string;
  end
end
