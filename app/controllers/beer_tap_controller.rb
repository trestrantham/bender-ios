class BeerTapController < UIViewController
  def self.controller
    @controller ||= BeerTapController.new
  end

  def viewDidLoad
    super
    self.title = "Taps"
    @taps = []

    @table ||= UITableView.alloc.initWithFrame(self.view.bounds)
		@table.dataSource = self
		@table.delegate = self
		@table.addPullToRefreshWithActionHandler(Proc.new { load_data })
    self.view.addSubview @table

    self.navigationItem.rightBarButtonItem ||= UIBarButtonItem.alloc.initWithTitle(
                                                  "Settings", 
                                                  style:UIBarButtonItemStylePlain, 
                                                  target:self, 
                                                  action:"show_settings")

		load_data
  end

	def load_data
    return if App::Persistence[:api_url].blank?

    if !AppHelper.valid_url?(App::Persistence[:api_url])
      App.alert("Invalid URL.")
      return
    end

    BW::HTTP.get("#{App::Persistence[:api_url]}/admin/beer_taps.json") do |response|
      if response.ok?
        json = p response.body.to_str
        @taps = BW::JSON.parse json
        
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

	def tableView(tableView, numberOfRowsInSection:section)
		@taps.size
	end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuseIdentifier)
    end

		cell.textLabel.text = @taps[indexPath.row][:name]
    cell
  end

	def tableView(tableView, didSelectRowAtIndexPath:indexPath)
		beer_tap = @taps[indexPath.row]
		user_controller ||= UserController.alloc.initWithBeerTap(beer_tap)
		self.navigationController.pushViewController(user_controller, animated:true)
	end

  def show_settings
    @settings ||= SettingsController.new
    @settings.parent_controller = self
    @settings_navigation = UINavigationController.alloc.initWithRootViewController(@settings)
    self.presentModalViewController(@settings_navigation, animated:true)
  end
end