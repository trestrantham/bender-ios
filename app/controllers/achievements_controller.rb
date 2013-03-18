class AchievementsController < UITableViewController
  def viewDidLoad
    super

    # tableView.rowHeight = 52
    @achievements = [{achievement_name: "The Lush", achievement_desc: "MOST TOTAL OZ POURED", name: "Tres T.", value: 123.45}, 
                     {achievement_name: "Designated Driver", achievement_desc: "LEAST TOTAL OZ POURED", name: "Dan M.", value: 1.2}, 
                     {achievement_name: "Big Gulp", achievement_desc: "LARGEST SINGLE POUR", name: "David G.", value: 23.9}]

    tableView.backgroundColor = "#333".uicolor
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine
    tableView.separatorColor = "#111".uicolor

    # load_data
    # setup_observers
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

    cell.achievement_name.text = @achievements[index_path.row][:achievement_name]
    cell.achievement_desc.text = @achievements[index_path.row][:achievement_desc].to_s.upcase
    cell.name.text = @achievements[index_path.row][:name]
    cell.value.text = "#{@achievements[index_path.row][:value].to_f.round(1)} oz".upcase

    cell
  end
end
