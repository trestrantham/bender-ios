class PourController < UIViewController
  def initWithBeerTap(beer_tap, user: user)
    self.init

    if beer_tap.is_a?(Hash)
      @beer_tap = beer_tap
    elsif beer_tap.is_a?(Integer) || beer_tap.is_a?(Fixnum)
      @beer_tap = { id: beer_tap }
      get_beer_tap(@beer_tap)
    else
      puts "ERROR: Bad beer_tap"
    end

    if user.is_a?(Hash)
      @user = user
    elsif user.is_a?(Integer) || user.is_a?(Fixnum)
      @user = { id: user }
      get_user(@user)
    else
      puts "ERROR: Bad user"
    end

    @beer_tap.symbolize_keys!
    @user.symbolize_keys!
    @last_update = nil
    self
  end

  def viewDidLoad
    super
    self.title = "Pour"
    self.view.backgroundColor = UIColor.whiteColor

    setup_view

    @pour_status_button.when(UIControlEventTouchUpInside) { end_pour }

    start_pour
  end

  def setup_view
    @pour_volume_label = UILabel.alloc.initWithFrame [[0,0], [320, 200]]
    @pour_volume_label.font = UIFont.boldSystemFontOfSize(72)
    @pour_volume_label.text = "0.0 oz"
    @pour_volume_label.textAlignment = UITextAlignmentCenter
    @pour_volume_label.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2 - 100)
    self.view.addSubview @pour_volume_label

    @beer_name = UILabel.alloc.initWithFrame(CGRectMake(20, 240, 344, 40))
    @beer_name.font = UIFont.boldSystemFontOfSize(24)
    @beer_name.text = @beer_tap && @beer_tap.fetch(:name, "No Beer")
    @beer_name.textAlignment = UITextAlignmentLeft
    @beer_name.backgroundColor = UIColor.lightGrayColor
    self.view.addSubview @beer_name

    @pour_status_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @pour_status_button.setTitle("Cancel Pour", forState:UIControlStateNormal)
    @pour_status_button.setTitle("Pour Complete!", forState:UIControlStateDisabled)
    @pour_status_button.sizeToFit
    @pour_status_button.center = CGPointMake(self.view.frame.size.width / 2, @pour_volume_label.center.y + 75)
    self.view.addSubview @pour_status_button
  end

  def start_pour
    puts ''
    puts "PourController > start_pour"

    @pour_status_button.enabled = true
    @pour_complete = false
  end

  def update_pour(pour = {})
    puts ''
    puts "PourController > update_pour"
    
    start_pour
    @pour_volume_label.text = "#{(pour[:volume].to_f * 10.0).round / 10.0} oz"
    App.notification_center.postNotificationName("UserUpdateNotification", object: nil, userInfo: nil) # Keep the user alive

    if App::Persistence[:current_user].has_key?(:id) && pour.has_key?(:user_id)
      if App::Persistence[:current_user][:id].to_s != pour[:user_id].to_s
        puts "PourController > update_pour > User Changed!"
        pour_user = {pour: {user_id: App::Persistence[:current_user][:id]}}
        pour[:user_id] = App::Persistence[:current_user][:id]
        
        if !App::Persistence[:api_url].blank? && AppHelper.valid_url?(App::Persistence[:api_url])
          AppHelper.parse_api(:put, "/pours/#{pour[:id]}.json", {payload: pour_user}) do |response|
            puts "PourController > update_pour > PUT finished"
          end
        end
      end
    else
      puts "!!! PourController > update_pour > user_id is missing!"
    end

    @last_update = AppHelper.parse_date_string(pour[:updated_at].to_str, "yyyy-MM-dd'T'HH:mm:ssz")

    EM.add_timer App::Persistence[:pour_timeout].to_i do
      if (@last_update + App::Persistence[:pour_timeout].to_i) <= Time.now
        puts "PourController > update_pour: POUR TIMED OUT"
        end_pour(pour) if !@pour_complete
      end
    end
  end

  def end_pour(pour = {})
    if pour.fetch(:user_id, 0) == 0
      puts "PourController > end_pour > NO USER"
      # TODO(Tres): Add user choice view
    end

    @pour_status_button.enabled = false
    @pour_complete = true
    @last_update = nil

    self.navigationController.popToRootViewControllerAnimated(true) if self.navigationController
  end

  def get_beer_tap(beer_tap = {})
    puts ''
    puts "PourController > get_beer_tap"

    AppHelper.parse_api(:get, "/admin/beer_taps/#{beer_tap[:id]}.json") do |response|
      puts "PourController > get_beer_tap > GOT BEER TAP using #{App::Persistence[:api_url]}/admin/beer_taps/#{beer_tap[:id]}.json"
      json = p response.body.to_str
      @beer_tap = BW::JSON.parse json
      @beer_tap.symbolize_keys!
    end
  end

  def get_user(user = {})
    puts ''
    puts "PourController > get_user"

    AppHelper.parse_api(:get, "/users/#{user[:id]}.json") do |response|
      puts "PourController > get_user > GOT USER using #{App::Persistence[:api_url]}/users/#{user[:id]}.json"
      json = p response.body.to_str
      @user = BW::JSON.parse json
      @user.symbolize_keys!
    end
  end
end