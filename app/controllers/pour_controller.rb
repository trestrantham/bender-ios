class PourController < UIViewController
	def initWithBeerTap(beer_tap, user: user)
		puts ''
		puts "PourController > initWithBeerTap"
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

	def update_pour(pour = {})
		puts ''
		puts "PourController > update_pour"
		
		start_pour
		App.notification_center.postNotificationName("UserUpdateNotification", object: nil, userInfo: nil) # Keep the user alive
		@pour_volume_field.text = pour[:volume]
# puts "PourController > update_pour > App::Persistence[:current_user][:id]: #{App::Persistence[:current_user][:id]}"
# puts "PourController > update_pour > pour[:user_id]: #{pour[:user_id]}"
		if App::Persistence[:current_user].has_key?(:id) && pour.has_key?(:user_id) && App::Persistence[:current_user][:id] != pour[:user_id]
			pour_user = {pour: {user_id: App::Persistence[:current_user][:id]}}
			pour[:user_id] = App::Persistence[:current_user][:id]
puts "PourController > update_pour > User Changed!"
			BW::HTTP.put("#{App::Persistence[:api_url]}/pours/#{pour[:id]}.json", {payload: pour_user}) do |response|
				# TODO(Tres): Handle failure
				
puts "PourController > update_pour > PUT finished"
			end
		else
puts "PourController > update_pour > User didn't change. Doing nothing..."
		end

		@last_update = AppHelper.parse_date_string(pour[:updated_at].to_str, "yyyy-MM-dd'T'HH:mm:ssz")

		EM.add_timer App::Persistence[:pour_timeout].to_i do
			if @pour_complete || (@last_update + App::Persistence[:pour_timeout].to_i) <= Time.now
puts "PourController > update_pour: NOT active"
				end_pour(pour)
			else
puts "PourController > update_pour: still active"
			end
		end
	end

	def end_pour(pour = {})
		puts ''
		puts "PourController > end_pour: #{pour}"

		if pour.has_key?(:user_id) && pour[:user_id].to_i > 0
			puts "PourController > end_pour > USER PRESENT"
		else
			puts "PourController > end_pour > NO USER"

			# Add user choice view
		end

		@pour_status.enabled = false
		@pour_complete = true
		@last_update = nil
	end

	# TODO(Tres): refactor this to it's own module
	def get_beer_tap(beer_tap = {})
		puts ''
		puts "PourController > get_beer_tap"
# puts "PourController > get_beer_tap > beer_tap_id: #{beer_tap}"

		BW::HTTP.get("#{App::Persistence[:api_url]}/admin/beer_taps/#{beer_tap[:id]}.json") do |response|
			puts "PourController > get_beer_tap > GOT BEER TAP using #{App::Persistence[:api_url]}/admin/beer_taps/#{beer_tap[:id]}.json"
			json = p response.body.to_str
			@beer_tap = BW::JSON.parse json
			@beer_tap.symbolize_keys!
# puts "PourController > get_beer_tap > updated @beer_tap: #{@beer_tap}"
		end
	end

	# TODO(Tres): refactor this to it's own module
	def get_user(user = {})
		puts ''
		puts "PourController > get_user"
# puts "PourController > get_user > user_id: #{user}"

		BW::HTTP.get("#{App::Persistence[:api_url]}/users/#{user[:id]}.json") do |response|
			puts "PourController > get_user > GOT USER using #{App::Persistence[:api_url]}/users/#{user[:id]}.json"
			json = p response.body.to_str
			@user = BW::JSON.parse json
			@user.symbolize_keys!
# puts "PourController > get_user > updated @user: #{@user}"
		end
	end
end