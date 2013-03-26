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

    @refresh_control = UIRefreshControl.new
    @refresh_control.addTarget(self, action: "load_data", forControlEvents: UIControlEventValueChanged)
    @refresh_control.tintColor = "#2481c2".uicolor
    self.refreshControl = @refresh_control

    load_data

    @pour_timeout_observer = App.notification_center.observe "PourTimeoutNotification" do |_|
      load_data
    end
  end

  def viewDidUnload
    App.notification_center.unobserve @pour_timeout_observer
    @pour_timeout_observer = nil
  end

  def load_data
    puts ""
    puts "BeerListController > load_data"

    return if App::Persistence[:api_url].blank?

    @refresh_control.tintColor = "#a6cce6".uicolor

    AppHelper.parse_api(:get, "/kegs.json") do |response|
      # TODO(Tres): Add error checking
      @beers = BW::JSON.parse response.body

      # Map the beer_tap_id to the index path
      @beers_index_hash = {}
      @beers.each_with_index { |beer, index| @beers_index_hash[beer[:beer_tap_id].to_i] = index }

      tableView.reloadData
      @refresh_control.endRefreshing
      @refresh_control.tintColor = "#2481c2".uicolor
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
    cell.beer_brewery.text = beer[:brewery]

    cell.set_beer_style beer[:style]
    cell.set_beer_abv beer[:abv]
    cell.set_keg_tapped_on "#{AppHelper.parse_date_string(beer[:started_at], 'yyyy-MM-dd\'T\'HH:mm:ssz').relative_date_string}"

    empty_date = AppHelper.parse_date_string(beer[:projected_empty], "yyyy-MM-dd\'T\'HH:mm:ssz")
    if empty_date
      cell.set_keg_empty_on "#{empty_date.relative_date_string(true)}"
    else
      cell.set_keg_empty_on "--"
    end

    cell.keg_volume_remaining.text = beer[:remaining].to_f.round(1).to_s
    cell.keg_volume_poured.text = beer[:poured].to_f.round(1).to_s

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
