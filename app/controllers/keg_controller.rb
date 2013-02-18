class KegController < UIViewController
  def viewDidLoad
    super

    self.title = "Kegs"

    @table = UITableView.alloc.initWithFrame(self.view.bounds)
    self.view.addSubview @table

    @table.dataSource = self
    @kegs = []

		@table.addPullToRefreshWithActionHandler(
			Proc.new do
				loadData
			end
		)

		loadData
  end

	def loadData
		BW::HTTP.get("#{App::Persistence[:api_url]}/admin/kegs.json") do |response|
			json = p response.body.to_str
			@kegs = BW::JSON.parse json
			
			@table.reloadData
			@table.pullToRefreshView.stopAnimating
		end
	end

	def numberOfSectionsInTableView(tableView)
		1
	end

	def tableView(tableView, numberOfRowsInSection:section)
		@kegs.size
	end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuseIdentifier)
    end

		cell.textLabel.text = @kegs[indexPath.row][:name]
    cell
  end
end