class UserController < UIViewController
	def initWithTap(beer_tap)
		puts "UserController > initWithTap: beer_tap: #{beer_tap}"
		self.init

		if beer_tap.is_a? Hash
			@beer_tap = beer_tap
		elsif beer_tap.is_a? Integer
			@beer_tap = get_tap(beer_tap)
		else
			puts "ERROR: Bad beer_tap"
		end

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
		user = @users[indexPath.row]
		pour_controller = PourController.alloc.initWithBeerTap(@beer_tap, user: user)
		self.navigationController.pushViewController(pour_controller, animated: true)
	end

		# TODO(Tres): refactor this to it's own module
	def get_tap(beer_tap)
		return {"gpio_pin"=>17, "id"=>1, "name"=>"Tap1", "temperature_sensor_id"=>nil, "updated_at"=>"2013-02-10T05:18:18Z", "created_at"=>"2013-02-10T05:18:18Z"}
	end
end