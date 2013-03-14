class BeerListController < UITableViewController
  TEXT_COLOR_LIGHT = "#666".uicolor

  def viewDidLoad
    super

    self.title = "On Tap"
    @beers = []
    @beers_index_hash = {}
    @index_path = nil

    tableView.rowHeight = 232
    tableView.backgroundColor = "#333".uicolor
    tableView.separatorColor = :clear.uicolor

    tableView.layer.masksToBounds = true
    tableView.layer.borderColor = :black.uicolor.CGColor
    tableView.layer.borderWidth = 1

    tableView.addPullToRefreshWithActionHandler( Proc.new { load_data } )

    load_data
  end

  def load_data
    puts ""
    puts "BeerListController > load_data"

    return if App::Persistence[:api_url].blank?

    AppHelper.parse_api(:get, "/kegs.json") do |response|
      # TODO(Tres): Add error checking
      @beers = BW::JSON.parse response.body

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

    tableView.selectRowAtIndexPath(@index_path,
                         animated: false,
                   scrollPosition: UITableViewScrollPositionNone)

    tableView.scrollToRowAtIndexPath(@index_path, 
                   atScrollPosition: UITableViewScrollPositionNone,
                           animated: true)
  end

  def reset_beer
    puts ""
    puts "BeerListController > reset_beer"

    tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow, animated: true)
    @index_path = nil
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @beers.size
  end

  def tableView(tableView, cellForRowAtIndexPath: index_path)
    @reuse_identifier ||= "beer_cell_identifier"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuse_identifier) || begin
      BeerCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuse_identifier)
    end

    beer = @beers[index_path.row]
    cell.beer_name.text = beer[:name]
    cell.beer_brewery.text = "New Holland Brewery"

    cell.set_beer_style "Imperial/Double IPA" 
    cell.set_beer_abv "7.3"
    cell.set_keg_tapped_on "#{AppHelper.parse_date_string(beer[:started_at], 'yyyy-MM-dd\'T\'HH:mm:ssz').relative_date_string}"
    cell.set_keg_empty_on beer[:projected_empty]

    cell.keg_volume_remaining.text = beer[:remaining]
    cell.keg_volume_poured.text = beer[:poured]

    cell.show_shadow(:top) if index_path.row == 0
    cell.show_shadow(:bottom) if index_path.row == @beers.size - 1

    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:index_path)
    if @index_path == tableView.indexPathForSelectedRow
      tableView.deselectRowAtIndexPath(index_path, animated: true) 
      @index_path = nil
    else
      @index_path = index_path
    end
  end
end
