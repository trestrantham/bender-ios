class ActivityController < UIViewController
  def viewDidLoad
    super

    self.title = "Recent Activity"
    @activities = [{name:"Tres T. poured 8.1 oz of Homebrew"}, {name:"David G. poured 6.3 oz of Homebrew"}, {name:"Tim B. poured 9.4 oz of Homebrew"}]

    @table_view = UITableView.alloc.initWithFrame([[0, 0], [388, 211]], style: UITableViewStyleGrouped)
    @table_view.delegate = self
    @table_view.dataSource = self
    @table_view.separatorStyle = UITableViewCellSeparatorStyleNone
    @table_view.backgroundView = nil

    self.view << @table_view

    #load_data
  end

  def load_data
    return if App::Persistence[:api_url].blank?

    AppHelper.parse_api(:get, "/activity/recent.json") do |response|
      @activities = BW::JSON.parse response.body
      
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
    @reuseIdentifier ||= "CELL_IDENTIFIER"

    cell = table_view.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuseIdentifier)
    end

    cell.textLabel.text = @activities[index_path.row][:name]
    cell.backgroundColor = :clear.uicolor
    cell
  end

  def tableView(table_view, didSelectRowAtIndexPath:index_path)
    table_view.deselectRowAtIndexPath(index_path, animated: true)
  end
end
