class UserListController < UITableViewController
  def viewDidLoad
    super

    self.title = "Users"
    @users = []
    @users_index_hash = {}
    @index_path = nil
    
    tableView.addPullToRefreshWithActionHandler( Proc.new { load_data } )
    load_data
  end

  def load_data
    return if App::Persistence[:api_url].blank?

    AppHelper.parse_api(:get, "/users.json") do |response|
      json = p response.body.to_str
      @users = BW::JSON.parse json

      # Move Guest user to top
      guest = @users.select { |user| user[:id].to_i == 0 }
      @users.delete_if { |user| user[:id].to_i == 0 }
      @users.sort_by! { |user| user[:name] }
      @users.insert(0, guest.first) if guest

      # Map the user_id to the index path
      @users_index_hash = {}
      @users.each_with_index { |user, index| @users_index_hash[user[:id].to_i] = index }

      tableView.reloadData
      tableView.pullToRefreshView.stopAnimating
    end
  end

  def update_user(pour)
    puts ""
    puts "UserListController > update_user"
    puts "#{pour}"

    user_id = pour.has_key?(:user_id) ? pour[:user_id].to_i : 0
    current_index = tableView.indexPathForSelectedRow.nil? ? -1 : tableView.indexPathForSelectedRow.row # Ignores section
puts "user_id: #{user_id}"
puts "current_index: #{current_index}"
puts "@users_index_hash: #{@users_index_hash}"
    # Check if the incoming pour has a user and if it's different than our currently selected user
    if @users_index_hash[user_id] != current_index #&& user_id > 0
      section = 0 # change if we need to use a sectioned list of beers
      @index_path = NSIndexPath.indexPathForRow(@users_index_hash[user_id], inSection: section)

      tableView.selectRowAtIndexPath(@index_path,
                           animated: false,
                     scrollPosition: UITableViewScrollPositionNone)

      tableView.scrollToRowAtIndexPath(@index_path, 
                     atScrollPosition: UITableViewScrollPositionNone,
                             animated: true)

      App.notification_center.post("UserUpdateNotification", nil, @users[@users_index_hash[user_id]])
    end
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @users.size
  end

  def tableView(tableView, cellForRowAtIndexPath: index_path)
    @reuse_identifier ||= "CELL_IDENTIFIER"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuse_identifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuse_identifier)
    end

    cell.textLabel.text = @users[index_path.row][:name]
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:index_path)
    if @index_path == tableView.indexPathForSelectedRow
      tableView.deselectRowAtIndexPath(index_path, animated: true) 
      @index_path = nil
    else
      @index_path = index_path
    end
    
    user = @users[index_path.row]
    App.notification_center.post("UserUpdateNotification", nil, user)
#
#   user_detail_controller ||= UserDetailController.alloc.initWithFrame(self.view.bounds, user: user)
#   self.navigationController.pushViewController(user_detail_controller, animated: true)
#
#   tableView.deselectRowAtIndexPath(index_path, animated: true)
  end
end