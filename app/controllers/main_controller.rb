class MainController < UIViewController
  def viewDidLoad
    puts ""
    puts "MainController > viewDidLoad"

    super

    @current_pour = nil
    @current_user_id = nil

# !!! If current pour (not active but not yet timed out) and user is clicked,
# !!! send PUT to update user
# !!! Follow same @current_user_id logic to maintain state
# !!! If current pour and current user, send PUT no matter when user is clicked

    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    self.view.backgroundColor = UIColor.blueColor

    # Setup container views 
    @beers_view = UIView.alloc.initWithFrame(CGRectMake(0, 0, 480, 753))
    @users_view = UIView.alloc.initWithFrame(CGRectMake(480, 0, 288, 753))
    @context_view = UIView.alloc.initWithFrame(CGRectMake(0, 753, 768, 251))

    self.view.addSubview(@beers_view)
    self.view.addSubview(@users_view)
    self.view.addSubview(@context_view)

    setup_child_controllers
    setup_handlers
    setup_observers
  end

  def viewDidUnload
    App.notification_center.unobserve @pour_update_observer
    App.notification_center.unobserve @settings_observer
    App.notification_center.unobserve @user_timeout_observer
    App.notification_center.unobserve @user_update_observer

    @beers_controller = nil
    @users_controller = nil
    @context_controller = nil
    @beers_view = nil
    @users_view = nil
    @context_view = nil
  end

  def shouldAutorotate
    true
  end

  def supportedInterfaceOrientations
    UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown
  end

# Setup

  def setup_child_controllers
    beer_list_controller = BeerListController.new
    beers_navigation = UINavigationController.alloc.initWithRootViewController(beer_list_controller)
    set_beers_controller(beers_navigation)
    update_beers_view

    user_list_controller = UserListController.new
    users_navigation = UINavigationController.alloc.initWithRootViewController(user_list_controller)
    set_users_controller(users_navigation)
    update_users_view

    context_controller = ContextController.new
    set_context_controller(context_controller)
    update_context_view

    @pour_controller = PourController.new
    @pour_controller.view.backgroundColor = UIColor.purpleColor
  end

  def setup_handlers
    # Setup faye handler
    @faye_handler = FayeHandler.new
    @faye_handler.setup
    # @faye_handler.connect # don't need to connect here since settings are reloaded each time the app is opened

    # Setup pour handler
    @pour_handler = PourHandler.new
    @pour_handler.setup

    # Setup Settings handler
    @settings_handler = SettingsHandler.new
  end

  def setup_observers
    @pour_update_observer = App.notification_center.observe "PourUpdateNotification" do |notification|
      pour_update(notification.userInfo.symbolize_keys) unless notification.userInfo.nil?
    end

    @pour_timeout_observer = App.notification_center.observe "PourTimeoutNotification" do |notification|
      end_pour
    end

    @user_update_observer = App.notification_center.observe "UserUpdatedNotification" do |notification|
      user_update(notification.userInfo.symbolize_keys) unless notification.userInfo.nil?
    end

    @user_timeout_observer = App.notification_center.observe "UserTimeoutNotification" do |notification|
      reset_user(notification.userInfo.symbolize_keys) unless notification.userInfo.nil?
    end

    @settings_observer = App.notification_center.observe "SettingsChangedNotification" { |_| reload_data }
  end

# Handle child views/controllers

  def update_beers_view
    @beers_controller.view.frame = @beers_view.bounds
    @beers_view.addSubview(@beers_controller.view)
  end

  def set_beers_controller(beers_controller)
    @beers_controller = beers_controller

    # handle view controller hierarchy
    self.addChildViewController(@beers_controller)
    @beers_controller.didMoveToParentViewController(self)

    update_beers_view if isViewLoaded
  end

  def update_users_view
    @users_controller.view.frame = @users_view.bounds
    @users_view.addSubview(@users_controller.view)
  end

  def set_users_controller(users_controller)
    @users_controller = users_controller

    # handle view controller hierarchy
    self.addChildViewController(@users_controller)
    @users_controller.didMoveToParentViewController(self)

    update_users_view if isViewLoaded
  end

  def update_context_view
    @context_controller.view.frame = @context_view.bounds
    @context_view.addSubview(@context_controller.view)
  end

  def set_context_controller(context_controller)
    @context_controller = context_controller

    # handle view controller hierarchy
    self.addChildViewController(@context_controller)
    @context_controller.didMoveToParentViewController(self)

    update_context_view if isViewLoaded
  end

# Handle events

  def reload_settings
    puts ""
    puts "MainController > reload_settings"

    # reload_data called after this completes via SettingsChangedNotification
    @settings_handler.reload_settings
  end

  def reload_data
    puts ""
    puts "MainController > reload_data"

    @beers_controller.popToRootViewControllerAnimated(false)
    @beers_controller.topViewController.load_data

    @users_controller.popToRootViewControllerAnimated(false)
    @users_controller.topViewController.load_data
  end

  def pour_update(pour)
    puts ""
    puts "MainController > pour_update > pour: #{pour}"

    @current_pour = pour
    @current_user_id = pour.fetch(:user_id, 0).to_i if @current_user_id.nil?

    @pour_handler.pour_update(pour, @current_user_id)

    @beers_controller.popToRootViewControllerAnimated(false)
    @beers_controller.topViewController.select_beer(pour)

    @users_controller.popToRootViewControllerAnimated(false)
    @users_controller.topViewController.update_user(@current_user_id)

    set_context_controller(@pour_controller)

    unless @pour_controller.isViewLoaded && @pour_controller.view.window
      @pour_controller.view.frame = [[0, 251], [@context_view.bounds.size.width, @context_view.bounds.size.height]]
      @context_view.addSubview(@context_controller.view)
      @pour_controller.view.slide(:up, 251) { }
    end
  end

  def user_update(user)
    puts ""
    puts "MainController > user_update > user: #{user}"
    
    if user.has_key?(:id)
      @current_user_id = user[:id].to_i 
      puts "MainController > user_update: setting current_user_id to #{@current_user_id}"

      @pour_handler.user_update(user)

      unless @current_pour.nil? || user[:id].to_i == @current_pour.fetch(:user_id, 0).to_i
        @pour_handler.update_pour_user(@current_pour[:id], user[:id])
      end
    end
  end

  def reset_beer
#    puts ""
#    puts "MainController > reset_beer"
#
#    @beers_controller.popToRootViewControllerAnimated(false)
#    @beers_controller.topViewController.reset
  end

  def reset_user(user)
    puts ""
    puts "MainController > reset_user"

    @users_controller.popToRootViewControllerAnimated(false)
    @users_controller.topViewController.reset_user(user.fetch(:id, 0))

    if @current_user_id == user.fetch(:id, 0).to_i
      puts "MainController > reset_user: resetting current_user_id"
      @current_user_id = nil
    end
  end

  def end_pour
    puts ""
    puts "MainController > end_pour"

    @beers_controller.popToRootViewControllerAnimated(false)
    @beers_controller.topViewController.reset_beer

    @current_pour = nil
    @pour_controller.view.slide(:down, 251) { }
  end
end
