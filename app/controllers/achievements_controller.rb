class AchievementsController < UITableViewController
  def viewDidLoad
    super

    @achievements = []

    tableView.backgroundColor = :clear.uicolor
    tableView.backgroundView = nil
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine
    tableView.separatorColor = "#111".uicolor

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
    App.notification_center.unobserve "PourTimeoutNotification"

    @pour_timeout_observer = nil
  end

  def load_data
    puts ""
    puts "AchievementsController > load_data"

    return if App::Persistence[:api_url].blank?

    @refresh_control.tintColor = "#a6cce6".uicolor

    AppHelper.parse_api(:get, "/admin/achievements.json") do |response|
      # TODO(Tres): Add error checking
      @achievements = BW::JSON.parse response.body 

      tableView.reloadData
      @refresh_control.endRefreshing
      @refresh_control.tintColor = "#2481c2".uicolor
    end
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @achievements.size
  end

  def tableView(tableView, cellForRowAtIndexPath: index_path)
    @reuse_identifier ||= "achievement_identifier"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuse_identifier) || begin
      AchievementCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuse_identifier)
    end

    cell.name.text = @achievements[index_path.row][:name]
    cell.desc.text = @achievements[index_path.row][:description].to_s.upcase
    cell.user_name.text = @achievements[index_path.row][:user_name]

    value = @achievements[index_path.row][:value]
    # cell.value.text = case @achievements[index_path.row][:value_type]
    #                   when "decimal"
    #                     "#{value.to_f.round(1)} oz".upcase
    #                   when "integer"
    #                     "#{value.to_f.round(0)}"
    #                   when "time"
    #                     "#{value.split(":").last.to_f.round(1)} seconds".upcase
    #                   end
    cell.value.text = @achievements[index_path.row][:value]

    cell
  end
end
