class SettingsHandler
  def reload_settings(&block)
    puts ""
    puts "SettingsHandler > reload_settings > api_url: #{App::Persistence[:api_url]}"

    return unless validate_settings # Make this more verbose

    AppHelper.parse_api(:get, "/admin/settings.json") do |response|
      json = p response.body.to_str

      settings = BW::JSON.parse json
      settings.symbolize_keys!
      settings.each { |key,val| App::Persistence[key] = val unless key == :api_url }

      if validate_settings
        #App.delegate.setup_faye
        block.call if block
      else
        App.alert("There is a problem with the settings from the server.")
      end
    end
  end

  def validate_settings
    true
  end
end