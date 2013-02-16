class PourController < UIViewController
	POUR_TIMEOUT = 5

	def initWithBeerTap(beer_tap, user: user)
		puts "PourController > initWithTap: beer_tap: #{beer_tap}"
		puts "PourController > initWithTap: user: #{user}"
		self.init

		if beer_tap.is_a? Hash
			@beer_tap = beer_tap
		elsif beer_tap.is_a? Integer
			@beer_tap = get_tap(beer_tap)
		else
			puts "ERROR: Bad beer_tap"
		end

		if user.is_a? Hash
			@user = user
		elsif user.is_a? Integer
			@user = get_user(user)
		else
			puts "ERROR: Bad user"
		end

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
    #@pour_status.setTitle("Pouring", forState:UIControlStateHighlighted)
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
		@pour_status.enabled = true
		@pour_complete = false
	end

	def update_pour(pour)
		App.notification_center.postNotificationName("UserUpdateNotification", object: nil, userInfo: nil)
		start_pour
		@current_pour = pour

		@last_update = parse_date(@current_pour["updated_at"].to_str)
		@pour_volume_field.text = @current_pour["volume"]

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
	end

	# TODO(Tres): refactor this to it's own module
	def get_tap(beer_tap)
		return {"gpio_pin"=>17, "id"=>1, "name"=>"Tap1", "temperature_sensor_id"=>nil, "updated_at"=>"2013-02-10T05:18:18Z", "created_at"=>"2013-02-10T05:18:18Z"}
	end

	# TODO(Tres): refactor this to it's own module
	def get_user(user)
		return {"name"=>"Tres", "id"=>1, "updated_at"=>"2013-02-10T05:18:49Z", "created_at"=>"2013-02-10T05:18:49Z"}
	end

	def parse_date(date_string)
		date_formatter = NSDateFormatter.alloc.init
		date_formatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
		date = date_formatter.dateFromString date_string
		date
	end
end