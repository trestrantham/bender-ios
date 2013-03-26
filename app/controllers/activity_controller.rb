class ActivityController < UIViewController
  ACTIVITY_WIDTH = 388
  ACHIEVEMENTS_WIDTH = 300
  HEADER_HEIGHT = 22
  PADDING = 20

  def viewDidLoad
    super

    setup_views
  end

  def setup_views
    @pours_label = UILabel.new
    @pours_label.frame = [[PADDING, PADDING / 2], [320, HEADER_HEIGHT]]
    @pours_label.font = :bold.uifont(18)
    @pours_label.textColor = "#a6cce6".uicolor
    @pours_label.shadowColor = "#111".uicolor
    @pours_label.shadowOffset = [0, -1]
    @pours_label.backgroundColor = :clear.uicolor
    @pours_label.layer.shadowColor = "#eee".uicolor.CGColor
    @pours_label.layer.shadowOffset = [0, 1]
    @pours_label.clipsToBounds = false
    @pours_label.text = "Recent Pours"
    self.view << @pours_label

    recent_activity_view = ShadowBox.alloc.initWithFrame([[PADDING, PADDING / 2 + HEADER_HEIGHT], [ACTIVITY_WIDTH, 251 - 40 - HEADER_HEIGHT]])
    @recent_activity_table_view = RecentActivityController.alloc.initWithStyle(UITableViewStylePlain)
    @recent_activity_table_view.view.frame = recent_activity_view.bounds
    @recent_activity_table_view.tableView.layer.cornerRadius = 5
    recent_activity_view << @recent_activity_table_view.tableView
    self.view << recent_activity_view

    @achievements_label = UILabel.new
    @achievements_label.frame = [[ACTIVITY_WIDTH + PADDING * 3, PADDING / 2], [320, HEADER_HEIGHT]]
    @achievements_label.font = :bold.uifont(18)
    @achievements_label.textColor = "#a6cce6".uicolor
    @achievements_label.shadowColor = "#111".uicolor
    @achievements_label.shadowOffset = [0, -1]
    @achievements_label.backgroundColor = :clear.uicolor
    @achievements_label.layer.shadowColor = "#eee".uicolor.CGColor
    @achievements_label.layer.shadowOffset = [0, 1]
    @achievements_label.clipsToBounds = false
    @achievements_label.text = "Achievements"
    self.view << @achievements_label

    achievements_view = ShadowBox.alloc.initWithFrame([[ACTIVITY_WIDTH + PADDING * 3, PADDING / 2 + HEADER_HEIGHT], [ACHIEVEMENTS_WIDTH, 251 - 40 - HEADER_HEIGHT]])
    @achievements_table_view = AchievementsController.alloc.initWithStyle(UITableViewStylePlain)
    @achievements_table_view.view.frame = achievements_view.bounds
    @achievements_table_view.tableView.layer.cornerRadius = 5
    achievements_view << @achievements_table_view.tableView
    self.view << achievements_view
  end
end
