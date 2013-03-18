class ActivityController < UIViewController
  ACTIVITY_WIDTH = 388
  ACHIEVEMENTS_WIDTH = 300
  HEADER_HEIGHT = 22
  PADDING = 20

  def viewDidLoad
    super

    @activities = {}

    setup_views
    load_data

    @refresh_time_views_observer = App.notification_center.observe "RefreshTimeViewsNotification" do |_|
      refresh_time_views
    end
  end

  def viewDidUnload
    App.notification_center.unobserve "RefreshTimeViewsNotification"

    @refresh_time_views_observer = nil
    @refresh_timer = nil
  end

  def setup_views
    @pours_label = UILabel.new
    @pours_label.frame = [[PADDING, PADDING / 2], [320, HEADER_HEIGHT]]
    @pours_label.font = :bold.uifont(18)
    @pours_label.textColor = "#a6cce6".uicolor
    @pours_label.shadowColor = "#111".uicolor
    @pours_label.shadowOffset = [0, -1]
    @pours_label.backgroundColor = :clear.uicolor
    # @pours_label.backgroundColor = :orange.uicolor
    @pours_label.layer.shadowColor = "#eee".uicolor.CGColor
    @pours_label.layer.shadowOffset = [0, 1]
    @pours_label.clipsToBounds = false
    @pours_label.text = "Recent Pours"
    self.view << @pours_label

    activity_view = ShadowBox.alloc.initWithFrame([[PADDING, PADDING / 2 + HEADER_HEIGHT], [ACTIVITY_WIDTH, 251 - 40 - HEADER_HEIGHT]])
    @activity_table_view = UITableView.plain(activity_view.bounds)
    @activity_table_view.delegate = self
    @activity_table_view.dataSource = self
    @activity_table_view.separatorStyle = UITableViewCellSeparatorStyleSingleLine
    @activity_table_view.separatorColor = "#111".uicolor
    @activity_table_view.backgroundView = nil
    @activity_table_view.backgroundColor = :clear.uicolor
    @activity_table_view.layer.cornerRadius = 5

    activity_view << @activity_table_view
    self.view << activity_view

    @achievements_label = UILabel.new
    @achievements_label.frame = [[ACTIVITY_WIDTH + PADDING * 3, PADDING / 2], [320, HEADER_HEIGHT]]
    @achievements_label.font = :bold.uifont(18)
    @achievements_label.textColor = "#a6cce6".uicolor
    @achievements_label.shadowColor = "#111".uicolor
    @achievements_label.shadowOffset = [0, -1]
    @achievements_label.backgroundColor = :clear.uicolor
    # @achievements_label.backgroundColor = :orange.uicolor
    @achievements_label.layer.shadowColor = "#eee".uicolor.CGColor
    @achievements_label.layer.shadowOffset = [0, 1]
    @achievements_label.clipsToBounds = false
    @achievements_label.text = "Achievements"
    self.view << @achievements_label

    achievements_view = ShadowBox.alloc.initWithFrame([[ACTIVITY_WIDTH + PADDING * 3, PADDING / 2 + HEADER_HEIGHT], [ACHIEVEMENTS_WIDTH, 251 - 40 - HEADER_HEIGHT]])
    @achievements_tableview = AchievementsController.alloc.initWithStyle(UITableViewStylePlain)
    @achievements_tableview.view.frame = achievements_view.bounds
    achievements_view << @achievements_tableview.view
    self.view << achievements_view

  end

  def load_data
    return if App::Persistence[:api_url].blank?

    AppHelper.parse_api(:get, "/activity/recent.json") do |response|
      @activities = BW::JSON.parse response.body
      puts "#{@activities}"
      @activity_table_view.reloadData
    end
  end

  def refresh_time_views
    puts "refreshing activity list times"

    selected_row = @activity_table_view.indexPathForSelectedRow
    @activity_table_view.reloadRowsAtIndexPaths(@activity_table_view.indexPathsForVisibleRows, withRowAnimation: UITableViewRowAnimationNone)
    @activity_table_view.selectRowAtIndexPath(selected_row, animated: false, scrollPosition: UITableViewScrollPositionNone) if selected_row
  end

  def numberOfSectionsInTableView(table_view)
    1
  end

  def tableView(table_view, numberOfRowsInSection: section)
    @activities.size
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

    activity = @activities[index_path.row]

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
