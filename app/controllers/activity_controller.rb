class ActivityController < UIViewController
  def viewDidLoad
    super

    self.title = "Recent Activity"

    @activities = {}

    @table_view = UITableView.grouped([[0, 0], [388, 191]])
    @table_view.delegate = self
    @table_view.dataSource = self
    @table_view.separatorStyle = UITableViewCellSeparatorStyleNone
    @table_view.backgroundView = nil

    self.view << @table_view

    load_data
  end

  def load_data
    return if App::Persistence[:api_url].blank?

    AppHelper.parse_api(:get, "/activity/recent.json") do |response|
      @activities = BW::JSON.parse response.body
      puts "#{@activities}"
      @table_view.reloadData
    end
  end

  def numberOfSectionsInTableView(table_view)
    1
  end

  def tableView(table_view, numberOfRowsInSection: section)
    @activities.size
  end

  def tableView(table_view, titleForHeaderInSection: section)
    "Recent Activity"
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
 
    activity = @activities[index_path.row]
puts "#{@activities[index_path.row]}"
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
    cell.backgroundColor = :clear.uicolor

    cell
  end

  def tableView(table_view, didSelectRowAtIndexPath:index_path)
    table_view.deselectRowAtIndexPath(index_path, animated: true)
  end

  def tableView(table_view, heightForHeaderInSection: section)
    44
  end

  def tableView(table_view, viewForHeaderInSection: section)
    header_label = UILabel.new
    header_label.frame = [[18, 0], [372, 44]]
    header_label.font = :bold.uifont(18)
    header_label.textColor = "#666".uicolor
    header_label.shadowColor = "#111".uicolor
    header_label.shadowOffset = [0, -1]
    header_label.backgroundColor = :clear.uicolor
    header_label.layer.shadowColor = "#eee".uicolor.CGColor
    header_label.layer.shadowOffset = [0, 1]
    header_label.clipsToBounds = false
    header_label.text = "Recent Activity"

    header_view = UIView.new
    header_view << header_label

    header_view
  end
end
