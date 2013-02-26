class UserController < UIViewController
	def initWithBeerTap(beer_tap)
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
    @users = []

    @table ||= UITableView.alloc.initWithFrame(self.view.bounds)
		@table.dataSource = self
		@table.delegate = self
		@table.addPullToRefreshWithActionHandler( Proc.new { load_data } )
		self.view.addSubview @table

		load_data
  end

  def viewDidDisappear(animated)
  	super(animated)

  	@pour_active = true
  end

	def load_data
		return if App::Persistence[:api_url].blank?

		if !AppHelper.valid_url?(App::Persistence[:api_url])
			App.alert("Invalid URL.")
			return
		end

		BW::HTTP.get("#{App::Persistence[:api_url]}/users.json") do |response|
			if response.ok?
				json = p response.body.to_str
				@users = BW::JSON.parse json

				@table.reloadData
				@table.pullToRefreshView.stopAnimating
			else
				App.alert("Server cannot be reached.")
			end
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
		user = @users[indexPath.row]
		App.notification_center.postNotificationName("UserUpdateNotification", object: nil, userInfo: user)

		pour_controller ||= PourController.alloc.initWithBeerTap(@beer_tap, user: user)
		self.navigationController.pushViewController(pour_controller, animated: true)
	end

	# TODO(Tres): refactor this to it's own module
	def get_beer_tap(beer_tap = {})
		puts ''
		puts "UserController > get_beer_tap"

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
				puts "UserController > get_beer_tap > GOT BEER TAP using #{App::Persistence[:api_url]}/admin/beer_taps/#{beer_tap[:id]}.json"
				json = p response.body.to_str
				@beer_tap = BW::JSON.parse json
				@beer_tap.symbolize_keys!
			else
				App.alert("Server cannot be reached.")
			end
		end
	end
end