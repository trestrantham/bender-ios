class MainController < UIViewController
  attr_accessor :beers_controller, :users_controller, :context_controller

  def viewDidLoad
    puts ""
    puts "MainController > viewDidLoad"

    super

    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    self.view.backgroundColor = UIColor.blueColor

    @beers_view = UIView.alloc.initWithFrame(CGRectMake(0, 0, 480, 753))
    @users_view = UIView.alloc.initWithFrame(CGRectMake(480, 0, 288, 753))
    @context_view = UIView.alloc.initWithFrame(CGRectMake(0, 753, 768, 251))

    self.view.addSubview(@beers_view)
    self.view.addSubview(@users_view)
    self.view.addSubview(@context_view)

    beer_list_controller = BeerListController.new
beer_list_controller.view.backgroundColor = UIColor.lightGrayColor
    beers_navigation = UINavigationController.alloc.initWithRootViewController(beer_list_controller)
    set_beers_controller(beers_navigation)

    user_list_controller = UserListController.new
user_list_controller.view.backgroundColor = UIColor.grayColor
    users_navigation = UINavigationController.alloc.initWithRootViewController(user_list_controller)
    set_users_controller(users_navigation)

    context_controller = ContextController.new
    set_context_controller(context_controller)

    update_beers_view
    update_users_view
    update_context_view

    # Setup faye handler
    @faye_handler = FayeHandler.new
    #@faye_handler.setup
    #@faye_handler.connect

    # Setup pour handler

    # Setup Settings handler
    @settings_handler = SettingsHandler.new

    @pour_observer = App.notification_center.observe "PourUpdateNotification" do |notification|
      pour_update(notification.userInfo.symbolize_keys) unless notification.userInfo.nil?
    end
  end

  def viewDidUnload
    App.notification_center.unobserve @pour_observer

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

    @settings_handler.reload_settings do
      puts "MainController > reload_settings > reloading data..."
      @faye_handler.reconnect
      reload_data
    end
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
    puts "MainController > update_pour > pour: #{pour}"

    @beers_controller.popToRootViewControllerAnimated(false)
    @beers_controller.topViewController.select_beer(pour)

    @users_controller.popToRootViewControllerAnimated(false)
    @users_controller.topViewController.update_user(pour)
  end
end