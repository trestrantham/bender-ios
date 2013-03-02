module AppHelper
  module_function

  def parse_date_string(date_string, format_string = "yyyy-MM-dd HH:mm:ss z")
    date_formatter = NSDateFormatter.alloc.init
    date_formatter.dateFormat = format_string
    date = date_formatter.dateFromString date_string
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