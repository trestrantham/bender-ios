class PourController < UIViewController
	def initWithBeerTap(beer_tap, user: user)
		self.init

		if beer_tap.is_a? Hash
			@beer_tap = beer_tap
		elsif beer_tap.is_a? Integer
			@beer_tap = {id: beer_tap}
			get_beer_tap(@beer_tap)
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

		@pour_status.when(UIControlEventTouchUpInside) { end_pour }

    start_pour
  end

  def setup_view
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
  end

	def start_pour
		puts ''
		puts "PourController > start_pour"

		@pour_status.enabled = true
		@pour_complete = false
	end

	def update_pour(pour = {})
		puts ''
		puts "PourController > update_pour"
		
		start_pour
		@pour_volume_field.text = pour[:volume]
		App.notification_center.postNotificationName("UserUpdateNotification", object: nil, userInfo: nil) # Keep the user alive

		if App::Persistence[:current_user].has_key?(:id) && pour.has_key?(:user_id)
			if App::Persistence[:current_user][:id].to_s != pour[:user_id].to_s
				puts "PourController > update_pour > User Changed!"
				pour_user = {pour: {user_id: App::Persistence[:current_user][:id]}}
				pour[:user_id] = App::Persistence[:current_user][:id]
				
		    if !App::Persistence[:api_url].blank? && AppHelper.valid_url?(App::Persistence[:api_url])
			    BW::HTTP.put("#{App::Persistence[:api_url]}/pours/#{pour[:id]}.json", {payload: pour_user}) do |response|
			      if response.ok?
							puts "PourController > update_pour > PUT finished"
			      else
			      	puts "!!! PourController > update_pour > PUT FAILED!"
			        App.alert("Server cannot be reached.")
			      end
			    end
		    end
			end
		else
			puts "!!! PourController > update_pour > user_id is missing!"
		end

		@last_update = AppHelper.parse_date_string(pour[:updated_at].to_str, "yyyy-MM-dd'T'HH:mm:ssz")

		EM.add_timer App::Persistence[:pour_timeout].to_i do
			if @pour_complete || (@last_update + App::Persistence[:pour_timeout].to_i) <= Time.now
				puts "PourController > update_pour: POUR TIMED OUT"
				end_pour(pour)
			end
		end
	end

	def end_pour(pour = {})
		if !pour.has_key?(:user_id) || pour[:user_id].to_i == 0
			puts "PourController > end_pour > NO USER"
			# TODO(Tres): Add user choice view
		end

		@pour_status.enabled = false
		@pour_complete = true
		@last_update = nil
	end

	# TODO(Tres): refactor this to it's own module
	def get_beer_tap(beer_tap = {})
		puts ''
		puts "PourController > get_beer_tap"

		if App::Persistence[:api_url].blank?
			App.alert("API URL is required!")
			return
		end

		if !AppHelper.valid_url?(App::Persistence[:api_url])
			App.alert("Invalid URL.")
			return
		end

		BW::HTTP.get("#{App::Persistence[:api_url]}/admin/beer_taps/#{beer_tap[:id]}.json") do |response|
			if response.ok?
				puts "PourController > get_beer_tap > GOT BEER TAP using #{App::Persistence[:api_url]}/admin/beer_taps/#{beer_tap[:id]}.json"
				json = p response.body.to_str
				@beer_tap = BW::JSON.parse json
				@beer_tap.symbolize_keys!
			else
				App.alert("Server cannot be reached.")
			end
		end
	end

	# TODO(Tres): refactor this to it's own module
	def get_user(user = {})
		puts ''
		puts "PourController > get_user"

		if App::Persistence[:api_url].blank?
			App.alert("API URL is required!")
			return
		end

		if !AppHelper.valid_url?(App::Persistence[:api_url])
			App.alert("Invalid URL.")
			return
		end

		BW::HTTP.get("#{App::Persistence[:api_url]}/users/#{user[:id]}.json") do |response|
			if response.ok?
				puts "PourController > get_user > GOT USER using #{App::Persistence[:api_url]}/users/#{user[:id]}.json"
				json = p response.body.to_str
				@user = BW::JSON.parse json
				@user.symbolize_keys!
			else
				App.alert("Server cannot be reached.")
			end
		end
	end
end