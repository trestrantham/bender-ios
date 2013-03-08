class UserListController < UITableViewController
  def viewDidLoad
    super

    self.title = "Drinkers"
    @users = []
    @users_index_hash = {}

    tableView.rowHeight = 115
    tableView.backgroundColor = "#333".uicolor
    tableView.separatorColor = :clear.uicolor

    tableView.layer.masksToBounds = true
    tableView.layer.borderColor = :black.uicolor.CGColor
    tableView.layer.borderWidth = 1

    tableView.addPullToRefreshWithActionHandler( Proc.new { load_data } )

    load_data
  end

  def load_data
    puts ""
    puts "UserListController > load_data"

    return if App::Persistence[:api_url].blank?

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
      tableView.pullToRefreshView.stopAnimating
    end
  end

  def update_user(user_id)
    puts ""
    puts "UserListController > update_user: #{user_id}"

    @index_path = NSIndexPath.indexPathForRow(@users_index_hash[user_id], inSection: 0)

    tableView.selectRowAtIndexPath(@index_path,
                         animated: false,
                   scrollPosition: UITableViewScrollPositionNone)

    # tableView.scrollToRowAtIndexPath(@index_path, 
    #                atScrollPosition: UITableViewScrollPositionNone,
    #                        animated: true)

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

    cell.user_name.text = @users[index_path.row][:name]

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
