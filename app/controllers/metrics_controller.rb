class MetricsController < UITableViewController
  def viewDidLoad
    super
    self.title = "Metrics"
    @activities = [{name:"metrics"}, {name:"foo"}, {name:"bar"}, {name:"baz"}]
    #tableView.addPullToRefreshWithActionHandler( Proc.new { load_data } )
    #load_data
    # self.view << ShadowBox.initWithFrame([[20, 20], [100, 100]])
  end

  def load_data
    return if App::Persistence[:api_url].blank?

    AppHelper.parse_api(:get, "/activity/recent.json") do |response|
      json = p response.body.to_str
      @activities = BW::JSON.parse json

      @table.reloadData
      @table.pullToRefreshView.stopAnimating
    end
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @activities.size
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuseIdentifier)
    end

    cell.textLabel.text = @activities[indexPath.row][:name]
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  end
end
