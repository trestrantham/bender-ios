class UserController < UIViewController
	@pour_active = true

	def initWithBeerTap(beer_tap)
		puts "UserController > initWithBeerTap: beer_tap: #{beer_tap}"
		self.init

		if beer_tap.is_a? Hash
			@beer_tap = beer_tap
		elsif beer_tap.is_a? Integer
			@beer_tap = {id: beer_tap}
			get_beer_tap(beer_tap)
		else
			puts "ERROR: Bad beer_tap"
		end

		@beer_tap.symbolize_keys!
		@pour_active = false
		self
	end

  def viewDidLoad
    super

    self.title = "Users"

    @table = UITableView.alloc.initWithFrame(self.view.bounds)
    self.view.addSubview @table

		@table.dataSource = self
		@table.delegate = self
		@users = []

		@table.addPullToRefreshWithActionHandler(
			Proc.new do
				loadData
			end
		)

		loadData
  end

  def viewDidDisappear(animated)
  	super(animated)

  	@pour_active = true
  end

	def loadData
		BW::HTTP.get("#{App::Persistence[:api_url]}/users.json") do |response|
			json = p response.body.to_str
			@users = BW::JSON.parse json
			
			@table.reloadData
			@table.pullToRefreshView.stopAnimating
		end
	end

	def numberOfSectionsInTableView(tableView)
		1
	end

	def tableView(tableView, numberOfRowsInSection: section)
		@users.size
	end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuseIdentifier)
    end

		cell.textLabel.text = @users[indexPath.row][:name]
    cell
  end

	def tableView(tableView, didSelectRowAtIndexPath:indexPath)
		puts ''
		puts "UserController > didSelectRowAtIndexPath"

		user = @users[indexPath.row]
		App.notification_center.postNotificationName("UserUpdateNotification", object: nil, userInfo: user)

		if !@pour_active
			puts "UserController > didSelectRowAtIndexPath > pour NOT active"
			pour_controller = PourController.alloc.initWithBeerTap(@beer_tap, user: user)
			self.navigationController.pushViewController(pour_controller, animated: true)
		else
			puts "UserController > didSelectRowAtIndexPath > pour active"
			pour_user = {pour: {user_id: user[:id]}}
			BW::HTTP.put("#{App::Persistence[:api_url]}/pours/#{pour[:id]}.json", {payload: pour_user}) do |response|
				# TODO(Tres): Handle failure
				
				puts "UserController > didSelectRowAtIndexPath > PUT finished using #{App::Persistence[:api_url]}/pours/#{pour[:id]}.json"

				self.navigationController.popToRootViewControllerAnimated false
			end
		end
	end

	# TODO(Tres): refactor this to it's own module
	def get_beer_tap(beer_tap = {})
		puts ''
		puts "UserController > get_beer_tap"
# puts "UserController > get_beer_tap> beer_tap_id: #{beer_tap}"

		BW::HTTP.get("#{App::Persistence[:api_url]}/admin/beer_taps/#{beer_tap[:id]}.json") do |response|
			puts "UserController > get_beer_tap > GOT BEER TAP using #{App::Persistence[:api_url]}/admin/beer_taps/#{beer_tap[:id]}.json"
			json = p response.body.to_str
			@beer_tap = BW::JSON.parse json
			@beer_tap.symbolize_keys!
# puts "UserController > get_beer_tap > updated @beer_tap: #{@beer_tap}"
		end
	end
end