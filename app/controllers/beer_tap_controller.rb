class BeerTapController < UIViewController
  def viewDidLoad
    super

    self.title = "Taps"

    @table = UITableView.alloc.initWithFrame(self.view.bounds)
    self.view.addSubview @table

		@table.dataSource = self
		@table.delegate = self
		@taps = []

		@table.addPullToRefreshWithActionHandler(
			Proc.new do
				loadData
			end
		)

		loadData
  end

	def loadData
		BW::HTTP.get("#{App::Persistence[:api_url]}/admin/beer_taps.json") do |response|
			json = p response.body.to_str
			@taps = BW::JSON.parse json
			
			@table.reloadData
			@table.pullToRefreshView.stopAnimating
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
		user_controller = UserController.alloc.initWithTap(beer_tap)
		self.navigationController.pushViewController(user_controller, animated:true)
	end
end