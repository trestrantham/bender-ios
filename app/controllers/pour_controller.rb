class PourController < UIViewController
	POUR_TIMEOUT = 5

	def initWithBeerTap(beer_tap, user: user)
		puts ''
		puts "PourController > initWithBeerTap: beer_tap: #{beer_tap}"
		puts "PourController > initWithBeerTap: user: #{user}"
		self.init

		if beer_tap.is_a? Hash
			@beer_tap = beer_tap
		elsif beer_tap.is_a? Integer
			# @beer_tap = get_tap(beer_tap)
			# get_tap(beer_tap)
			@beer_tap = {id: beer_tap}
		else
			puts "ERROR: Bad beer_tap"
		end

		if user.is_a? Hash
			@user = user
		elsif user.is_a? Integer
			@user = {id: user}
			get_user(@user)
		else
			puts "ERROR: Bad user"
		end

		@beer_tap.symbolize!
		@user.symbolize!

		@last_update = nil
		@current_pour = nil

		self
	end

  def viewDidLoad
    super

    self.title = "Pour"
    self.view.backgroundColor = UIColor.whiteColor

    @pour_volume_field = UITextField.alloc.initWithFrame [[0,0], [160, 26]]
    @pour_volume_field.placeholder = "#abcabc"
    @pour_volume_field.textAlignment = UITextAlignmentCenter
    @pour_volume_field.autocapitalizationType = UITextAutocapitalizationTypeNone
    @pour_volume_field.borderStyle = UITextBorderStyleRoundedRect
    @pour_volume_field.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2 - 100)
    self.view.addSubview @pour_volume_field
    @pour_volume_field.enabled = false

		@pour_status = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @pour_status.setTitle("Cancel Pour", forState:UIControlStateNormal)
    @pour_status.setTitle("Pour Complete!", forState:UIControlStateDisabled)
    @pour_status.sizeToFit
    @pour_status.center = CGPointMake(self.view.frame.size.width / 2, @pour_volume_field.center.y + 40)
    self.view.addSubview @pour_status

		@pour_status.when(UIControlEventTouchUpInside) do
			end_pour
		end

    start_pour
  end


	def start_pour
		puts ''
		puts "PourController > start_pour"
		@pour_status.enabled = true
		@pour_complete = false
	end

	def update_pour(pour)
		puts ''
		puts "PourController > update_pour"

		App.notification_center.postNotificationName("UserUpdateNotification", object: nil, userInfo: nil)
		start_pour

		@current_pour = pour
		@current_pour[:user_id] = @user[:id]
		@last_update = AppHelper.parse_date_string(@current_pour[:updated_at].to_str, "yyyy-MM-dd HH:mm:ss z")
		@pour_volume_field.text = @current_pour[:volume]

		EM.add_timer (POUR_TIMEOUT) do
			if @pour_complete || (@last_update + POUR_TIMEOUT) <= Time.now
				puts "PourController > update_pour: NOT active"
				end_pour
			else
				puts "PourController > update_pour: still active"
			end
		end
	end

	def end_pour
		puts ''
		puts "PourController > end_pour"
		@pour_status.enabled = false
		@pour_complete = true
		@last_update = nil

		#if ticks > 0, send back
		puts "PourController > end_pour > @current_pour: #{@current_pour}"
		#BW::HTTP.put("#{App::Persistence[:api_url]}/pours", {payload: data}) do |response|
		#	json = p response.body.to_str
		#	@pour = BW::JSON.parse json
		#end
		@current_pour = nil
	end

	# TODO(Tres): refactor this to it's own module
	def get_tap(beer_tap_id = 0)
		puts "PourController > get_user > updating @beer_tap: #{@beer_tap}"
		BW::HTTP.get("#{App::Persistence[:api_url]}/admin/beer_taps/#{beer_tap_id}.json") do |response|
			json = p response.body.to_str
			@beer_tap = BW::JSON.parse json
			@beer_tap.symbolize!
			puts "PourController > get_user > updated @beer_tap: #{@beer_tap}"
		end
		# return {"gpio_pin"=>17, "id"=>1, "name"=>"Tap1", "temperature_sensor_id"=>nil, "updated_at"=>"2013-02-10T05:18:18Z", "created_at"=>"2013-02-10T05:18:18Z"}
	end

	# TODO(Tres): refactor this to it's own module
	def get_user(user_id = 0)
		puts "PourController > get_user > updating @user: #{@user}"
		BW::HTTP.get("#{App::Persistence[:api_url]}/users/#{user_id}.json") do |response|
			json = p response.body.to_str
			@user = BW::JSON.parse json
			@user.symbolize!
			puts "PourController > get_user > updated @user: #{@user}"
		end
		# return {"name"=>"Tres", "id"=>1, "updated_at"=>"2013-02-10T05:18:49Z", "created_at"=>"2013-02-10T05:18:49Z"}
	end
end