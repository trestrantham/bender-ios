class SettingsController < Formotion::FormController
  attr_accessor :parent_controller
  @parent_controller = nil

  def init
    form = Formotion::Form.new({
      sections: [{
        rows: [{
          title: "API URL",
          key: :api_url,
          value: App::Persistence[:api_url],
          placeholder: "http://",
          type: :string,
          auto_correction: :no,
          auto_capitalization: :none
        }, {
          title: "Faye URL",
          key: :faye_url,
          value: App::Persistence[:faye_url],
          placeholder: "http://",
          type: :string,
          auto_correction: :no,
          auto_capitalization: :none,
          editable: false
        }, {
          title: "User Timeout",
          key: :user_timeout,
          value: App::Persistence[:user_timeout],
          placeholder: "10",
          type: :string,
          auto_correction: :no,
          auto_capitalization: :none,
          editable: false
        }, {
          title: "Pour Timeout",
          key: :pour_timeout,
          value: App::Persistence[:pour_timeout],
          placeholder: "5",
          type: :string,
          auto_correction: :no,
          auto_capitalization: :none,
          editable: false
        }]
      }]
    })

    form.on_submit do
      self.save
    end
    super.initWithForm(form)
  end

  def viewDidLoad
    super
    self.title = "Settings"

    self.navigationItem.leftBarButtonItem ||= UIBarButtonItem.cancel { cancel }
    self.navigationItem.rightBarButtonItem ||= UIBarButtonItem.save { save }
  end

  def viewDidDisappear(animated)
    super(animated)
    @table_data = nil
  end

  def save
    @form_data = self.form.render
    puts ""
    puts "SettingsController > save > @form_data: #{@form_data}"

    if @form_data.fetch(:api_url, "") == ""
      App.alert("API URL is required!")
      return 
    end

    # Ensure we have a HTTP(S) server
    if !@form_data[:api_url].to_s.hasPrefix("http://") && !@form_data[:api_url].to_s.hasPrefix("https://")
      App.alert("API URL must being with http:// or https://")
      return
    end

    # Trim trailing "/" if needed
    @form_data[:api_url] = @form_data[:api_url].gsub(/\/+$/, '') if @form_data[:api_url][-1].to_s == "/"

    if !AppHelper.valid_url?(@form_data[:api_url])
      App.alert("Invalid URL.")
      return
    end

    if @form_data[:api_url].to_s == App::Persistence[:api_url].to_s
      self.dismissModalViewControllerAnimated(true)
      return
    end

    # TODO(Tres): Set spinner
    BW::HTTP.get(@form_data[:api_url]) do |response|
      # TODO(Tres): Stop spinner
      if response.ok?
        puts "#{@form_data[:api_url]}"
        App::Persistence[:api_url] = @form_data[:api_url]
        #AppHelper.reload_settings
        #@parent_controller.reload_data if @parent_controller
        @parent_controller.reload_settings
        self.dismissModalViewControllerAnimated(true)
      else
        App.alert("Server cannot be reached.")
      end
    end
  end

  def cancel
    self.dismissModalViewControllerAnimated(true)
  end
end
