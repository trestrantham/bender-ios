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

  def generate_gravatar_url(email, image_size = 50)
    cleansed_email = email.gsub(/\s+/,"").downcase if email

    return "" unless cleansed_email

    digest = RmDigest::MD5.hexdigest(cleansed_email)
    "http://www.gravatar.com/avatar/#{digest}?s=#{image_size}"
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
 
  def relative_date_string(capitalize = false)
    now = NSDate.date
    delta = self.timeIntervalSinceDate(now)

    calendar = NSCalendar.currentCalendar
    units = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
    components = calendar.components(units, fromDate: self, toDate: now, options: 0)

    relative_string = ""
    seconds = components.second.abs
    minutes = components.minute.abs
    hours = components.hour.abs
    days = components.day.abs
    months = components.month.abs
    years = components.year.abs

    if delta.abs < 1 * MINUTE
        relative_string = seconds == 1 ? "one second" : "#{seconds} seconds"
    elsif delta.abs < 2 * MINUTE
        relative_string = "a minute"
    elsif delta.abs < 45 * MINUTE
        relative_string = "#{seconds >= 45 ? minutes + 1 : minutes} minutes"
    elsif delta.abs < 90 * MINUTE
        relative_string = "an hour"
    elsif delta.abs < 24 * HOUR
        relative_string = "#{minutes >= 45 ? hours + 1 : hours} hours"
    elsif delta.abs < 48 * HOUR
        relative_string = delta < 0 ? "yesterday" : "tomorrow"
    elsif delta.abs < 30 * DAY
        relative_string = "#{hours >= 18 ? days + 1 : days} days"
    elsif delta.abs < 12 * MONTH
        relative_string = months <= 1 ? "one month" : "#{months} months"
    else
        relative_string = years <= 1 ? "one year" : "#{years} years"
    end

    relative_string = ( delta < 0 ? "#{relative_string} ago" : "in #{relative_string}" ) unless ["yesterday", "tomorrow"].include? relative_string
    relative_string = relative_string.slice(0, 1).capitalize + relative_string.slice(1..-1) if capitalize

    relative_string
  end
end
