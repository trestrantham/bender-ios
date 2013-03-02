class BeerListController < UITableViewController
  def viewDidLoad
    super

    self.title = "On Tap"
    @beers = []
    @beers_index_hash = {}
    @index_path = nil
    
    tableView.addPullToRefreshWithActionHandler( Proc.new { load_data } )
    load_data

    # Manually highlight a cell
    # [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
  end

  def load_data
    return if App::Persistence[:api_url].blank?

    AppHelper.parse_api(:get, "/kegs.json") do |response|
      json = p response.body.to_str
      @beers = BW::JSON.parse json

      # Map the beer_tap_id to the index path
      @beers_index_hash = {}
      @beers.each_with_index { |beer, index| @beers_index_hash[beer[:beer_tap_id].to_i] = index }

      tableView.reloadData
      tableView.pullToRefreshView.stopAnimating
    end
  end

  def select_beer(pour)
    section = 0 # change if we use sectioned list of beers
    @index_path = NSIndexPath.indexPathForRow(@beers_index_hash[pour[:beer_tap_id].to_i].to_i, inSection: section)

    tableView.selectRowAtIndexPath(@index_path, animated: false, scrollPosition: UITableViewScrollPositionNone)
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @beers.size
  end

  def tableView(tableView, cellForRowAtIndexPath: index_path)
    @reuse_identifier ||= "CELL_IDENTIFIER"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuse_identifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuse_identifier)
    end

    cell.textLabel.text = @beers[index_path.row][:name]
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:index_path)
    puts "select"
    if @index_path == tableView.indexPathForSelectedRow
      tableView.deselectRowAtIndexPath(index_path, animated: true) 
      @index_path = nil
    else
      @index_path = index_path
    end
    #beer_tap = @beers[indexPath.row]
    #pour_controller ||= PourController.alloc.initWithBeerTap(beer_tap, user: 0)
    #self.navigationController.pushViewController(pour_controller, animated: true)
    #tableView.deselectRowAtIndexPath(index_path, animated: true)
  end
end