class RecentActivityController < UITableViewController
  ACTIVITY_WIDTH = 388

  def viewDidLoad
    super

    @recent_activity = []

    tableView.backgroundColor = :clear.uicolor
    tableView.backgroundView = nil
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine
    tableView.separatorColor = "#111".uicolor

    @refresh_control = UIRefreshControl.new
    @refresh_control.addTarget(self, action: "load_data", forControlEvents: UIControlEventValueChanged)
    @refresh_control.tintColor = "#2481c2".uicolor
    self.refreshControl = @refresh_control

    load_data

    @refresh_time_views_observer = App.notification_center.observe "RefreshTimeViewsNotification" do |_|
      refresh_time_views
    end
  end

  def viewDidUnload
    App.notification_center.unobserve "RefreshTimeViewsNotification"

    @refresh_time_views_observer = nil
  end

  def load_data
    return if App::Persistence[:api_url].blank?

    @refresh_control.tintColor = "#a6cce6".uicolor

    AppHelper.parse_api(:get, "/activity/recent.json") do |response|
      @recent_activity = BW::JSON.parse response.body
      puts "#{@recent_activity}"

      tableView.reloadData
      @refresh_control.endRefreshing
      @refresh_control.tintColor = "#2481c2".uicolor
    end
  end

  def refresh_time_views
    puts "refreshing activity list times"

    selected_row = tableView.indexPathForSelectedRow
    tableView.reloadRowsAtIndexPaths(tableView.indexPathsForVisibleRows, withRowAnimation: UITableViewRowAnimationNone)
    tableView.selectRowAtIndexPath(selected_row, animated: false, scrollPosition: UITableViewScrollPositionNone) if selected_row
  end

  def numberOfSectionsInTableView(table_view)
    1
  end

  def tableView(table_view, numberOfRowsInSection: section)
    @recent_activity.size
  end

  def tableView(table_view, cellForRowAtIndexPath: index_path)
    @reuse_identifier ||= "CELL_IDENTIFIER"

    cell = table_view.dequeueReusableCellWithIdentifier(@reuse_identifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuse_identifier)
    end

    cell.textLabel.font = :system.uifont(14)
    cell.textLabel.textColor = "#eee".uicolor
    cell.textLabel.shadowColor = "#111".uicolor
    cell.textLabel.shadowOffset = [0, -1]
    cell.textLabel.numberOfLines = 0
    cell.backgroundColor = :clear.uicolor

    line_view = UIView.alloc.initWithFrame([[0, 0], [ACTIVITY_WIDTH, 1]])
    line_view.backgroundColor = "#494949".uicolor
    cell << line_view

    activity = @recent_activity[index_path.row]

    split = activity[:user_name].split
    user_name = split[0]
    user_name += " #{split[1][0]}." if split[1]

    cell.textLabel.attributedText = "#{user_name}".attrd.bold + 
                                    " poured " + 
                                    "#{activity[:volume]}".attrd.bold +
                                    " oz of " +
                                    "#{activity[:beer_name]}".attrd.bold +
                                    " " +
                                    "#{AppHelper.parse_date_string(activity[:created_at], 'yyyy-MM-dd\'T\'HH:mm:ssz').relative_date_string}"

    cell
  end

  def tableView(table_view, didSelectRowAtIndexPath:index_path)
    table_view.deselectRowAtIndexPath(index_path, animated: true)
  end
end
