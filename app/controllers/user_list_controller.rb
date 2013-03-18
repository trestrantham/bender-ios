class UserListController < UITableViewController
  def viewDidLoad
    super

    self.title = "Drinkers"
    @users = []
    @users_index_hash = {}

    tableView.rowHeight = 66
    tableView.backgroundColor = "#333".uicolor
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone

    tableView.layer.masksToBounds = true
    tableView.layer.borderColor = :black.uicolor.CGColor
    tableView.layer.borderWidth = 1

    @refresh_control = UIRefreshControl.new
    @refresh_control.addTarget(self, action: "load_data", forControlEvents: UIControlEventValueChanged)
    @refresh_control.tintColor = "#2481c2".uicolor
    self.refreshControl = @refresh_control

    load_data

    setup_observers
  end

  def viewDidUnload
    App.notification_center.unobserve "UserCreatedNotification"
    App.notification_center.unobserve "PourTimeoutNotification"

    @user_created_observer = nil
    @pour_timeout_observer = nil
  end

  def load_data
    puts ""
    puts "UserListController > load_data"

    return if App::Persistence[:api_url].blank?
    @refresh_control.tintColor = "#a6cce6".uicolor

    AppHelper.parse_api(:get, "/users.json") do |response|
      # TODO(Tres): Add error checking
      @users = BW::JSON.parse response.body 

      # Move Guest user to top
      guest = @users.select { |user| user[:id].to_i == 0 }
      @users.delete_if { |user| user[:id].to_i == 0 }
      @users.sort_by! { |user| user[:name] }
      @users.insert(0, guest.first) if guest

      # Map the user_id to the index path
      @users_index_hash = {}
      @users.each_with_index { |user, index| @users_index_hash[user[:id].to_i] = index }

      tableView.reloadData
      @refresh_control.endRefreshing
      @refresh_control.tintColor = "#2481c2".uicolor
    end
  end
  
  def refresh_time_views
    puts "refreshing user list times"
      
    selected_row = tableView.indexPathForSelectedRow
    tableView.reloadRowsAtIndexPaths(tableView.indexPathsForVisibleRows, withRowAnimation: UITableViewRowAnimationNone)      
    tableView.selectRowAtIndexPath(selected_row, animated: false, scrollPosition: UITableViewScrollPositionNone) if selected_row
  end

  def setup_observers
    @user_created_observer = App.notification_center.observe "UserCreatedNotification" do |_|
      load_data      
    end

    @pour_timeout_observer = App.notification_center.observe "PourTimeoutNotification" do |_|
      load_data
    end

    @refresh_time_views_observer = App.notification_center.observe "RefreshTimeViewsNotification" do |_|
      refresh_time_views
    end
  end

  def update_user(user_id)
    puts ""
    puts "UserListController > update_user: #{user_id}"

    @index_path = NSIndexPath.indexPathForRow(@users_index_hash[user_id], inSection: 0)

    tableView.selectRowAtIndexPath(@index_path,
                         animated: false,
                   scrollPosition: UITableViewScrollPositionNone)

    App.notification_center.post("UserUpdatedNotification", nil, @users[@users_index_hash[user_id]])
  end

  def reset_user(user_id)
    puts ""
    puts "UserListController > reset_user: #{user_id}"

    index = @users_index_hash.fetch(user_id.to_i, 0)
    row = tableView.indexPathForSelectedRow.nil? ? nil : tableView.indexPathForSelectedRow.row

    if index == row
      tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow, animated: true)
      @index_path = nil
    end
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @users.size
  end

  def tableView(tableView, cellForRowAtIndexPath: index_path)
    @reuse_identifier ||= "user_cell_identifier"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuse_identifier) || begin
      UserCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuse_identifier)
    end

    user = @users[index_path.row]

    cell.user_name.text = user[:name]
    cell.set_user_email(user[:email])

    cell.last_drink.text = if user[:last_pour_at].nil?
                              "New drinker on #{AppHelper.parse_date_string(user[:created_at], 'yyyy-MM-dd\'T\'HH:mm:ssz', 'MMM d, yyyy')}"
                            else
                              "Last pour #{AppHelper.parse_date_string(user[:last_pour_at], 'yyyy-MM-dd\'T\'HH:mm:ssz').relative_date_string}"
                            end

    cell.show_shadow(:top) if index_path.row == 0
    cell.show_shadow(:bottom) if index_path.row == @users.size - 1

    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:index_path)
    if @index_path == tableView.indexPathForSelectedRow
      tableView.deselectRowAtIndexPath(index_path, animated: true) 
      @index_path = nil
    else
      @index_path = index_path
      user = @users[index_path.row]
      App.notification_center.post("UserUpdatedNotification", nil, user)
    end
  end
end
