class UserDetailController < UIViewController
  def initWithFrame(frame, user: user)
    puts "UserDetailController > initWithFrame > user: #{user}"
    self.init

    self.view.frame = frame
    @activities = [
      {date: "2013-02-25", oz: "8.2"}, 
      {date: "2013-02-26", oz: "12.3"}, 
      {date: "2013-02-27", oz: "0.5"}, 
      {date: "2013-02-28", oz: "10.8"}, 
      {date: "2013-03-01", oz: "8.2"}, 
    ]
    @user = {}

    if user.is_a? Hash
      @user = user
    elsif user.is_a? Integer
      @user = {id: user}
      get_user(@user)
    else
      puts "ERROR: Bad user"
    end

    @user.symbolize_keys!
    update_view

    self
  end

  def viewDidLoad
    puts "UserDetailController > viewDidLoad > @user: #{@user}"
    super
    self.title = @user && @user.has_key?(:name) ? @user[:name] : "No User"
    setup_view
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @activities.size
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuse_identifier ||= "CELL_IDENTIFIER"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuse_identifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue2, reuseIdentifier:@reuse_identifier)
    end

    cell.textLabel.text = @activities[indexPath.row][:date]
    cell.detailTextLabel.text = "#{@activities[indexPath.row][:oz]} oz"
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    @user_activity.deselectRowAtIndexPath(indexPath, animated: true)
  end

  def setup_view
    @user_picture = UILabel.alloc.initWithFrame(CGRectMake(20, 20, 344, 200))
    @user_picture.font = UIFont.boldSystemFontOfSize(24)
    @user_picture.text = "User Picture"
    @user_picture.textAlignment = UITextAlignmentCenter
    @user_picture.backgroundColor = UIColor.darkGrayColor
    self.view.addSubview @user_picture

    @user_name = UILabel.alloc.initWithFrame(CGRectMake(20, 240, 344, 40))
    @user_name.font = UIFont.boldSystemFontOfSize(24)
    @user_name.text = @user && @user.has_key?(:name) ? @user[:name] : "No User"
    @user_name.textAlignment = UITextAlignmentLeft
    @user_name.backgroundColor = UIColor.lightGrayColor
    self.view.addSubview @user_name

    @user_total_oz = UILabel.alloc.initWithFrame(CGRectMake(20, 300, 344, 40))
    @user_total_oz.font = UIFont.boldSystemFontOfSize(24)
    @user_total_oz.text = "Consumed a total of 123.4oz"
    @user_total_oz.textAlignment = UITextAlignmentLeft
    @user_total_oz.backgroundColor = UIColor.lightGrayColor
    self.view.addSubview @user_total_oz

    @user_total_oz = UILabel.alloc.initWithFrame(CGRectMake(20, 360, 344, 40))
    @user_total_oz.font = UIFont.boldSystemFontOfSize(24)
    @user_total_oz.text = "Joined on 2013-02-03"
    @user_total_oz.textAlignment = UITextAlignmentLeft
    @user_total_oz.backgroundColor = UIColor.lightGrayColor
    self.view.addSubview @user_total_oz

    @user_activity_label = UILabel.alloc.initWithFrame(CGRectMake(20, 420, 344, 40))
    @user_activity_label.font = UIFont.boldSystemFontOfSize(18)
    @user_activity_label.text = "User Activity"
    @user_activity_label.textAlignment = UITextAlignmentLeft
    @user_activity_label.backgroundColor = UIColor.lightGrayColor
    self.view.addSubview @user_activity_label

    @user_activity = UITableView.alloc.initWithFrame(CGRectMake(20, 460, 344, 224))
    @user_activity.dataSource = self
    @user_activity.delegate = self
    self.view.addSubview @user_activity
  end

  def update_view
    if @user
      self.title = @user[:name] if @user && @user.has_key?(:name)
      @user_name.text = @user[:name] if @user && @user.has_key?(:name)
    end
  end 

  def get_user(user = {})
    puts ''
    puts "PourController > get_user"

    AppHelper.parse_api(:get, "/users/#{user[:id]}.json") do |response|
      puts "PourController > get_user > GOT USER using #{App::Persistence[:api_url]}/users/#{user[:id]}.json"
      json = p response.body.to_str
      @user = BW::JSON.parse json
      @user.symbolize_keys!

      update_views
    end
  end
end