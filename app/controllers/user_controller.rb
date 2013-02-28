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
		@table.setAutoresizingMask(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)
		@table.addPullToRefreshWithActionHandler( Proc.new { load_data } )
		self.view.addSubview @table

		self.navigationItem.rightBarButtonItem ||= UIBarButtonItem.alloc.initWithBarButtonSystemItem(
																							UIBarButtonSystemItemAdd, 
																							target:self, 
																							action:"new_user")

		load_data
	end

	def viewDidDisappear(animated)
		super(animated)

		@pour_active = true
	end

	def load_data
		return if App::Persistence[:api_url].blank?

		AppHelper.parse_api(:get, "/users.json") do |response|
			json = p response.body.to_str
			@users = BW::JSON.parse json

			# Move Guest user to top
			guest = @users.select { |user| user[:id].to_i == 0 }
			@users.delete_if { |user| user[:id].to_i == 0 }
			@users.sort_by! { |user| user[:name] }
			@users.insert(0, guest.first) if guest

			@table.reloadData
			@table.pullToRefreshView.stopAnimating
		end
	end

	def new_user
		@user ||= AddUserController.new
		@user.parent_controller = self
		@user_navigation = MainController.alloc.initWithRootViewController(@user)
		@user_navigation.modalPresentationStyle = UIModalPresentationFormSheet
		self.presentModalViewController(@user_navigation, animated:true)
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

		@table.deselectRowAtIndexPath(indexPath, animated: true)
	end

	def get_beer_tap(beer_tap = {})
		puts ''
		puts "UserController > get_beer_tap"

		AppHelper.parse_api(:get, "/admin/beer_taps/#{beer_tap[:id]}.json") do |response|
			puts "UserController > get_beer_tap > GOT BEER TAP using #{App::Persistence[:api_url]}/admin/beer_taps/#{beer_tap[:id]}.json"
			json = p response.body.to_str
			@beer_tap = BW::JSON.parse json
			@beer_tap.symbolize_keys!
		end
	end
end