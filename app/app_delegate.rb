class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    @navigation_controller = UINavigationController.alloc.initWithRootViewController(BeerTapController.controller)
    @window.rootViewController = @navigation_controller
    @window.makeKeyAndVisible

    # Setup NotificationController
    @notification_controller = NotificationController.alloc.initWithNavigationController(@navigation_controller)
    @notification_controller.listen

    if App::Persistence[:api_url].blank? || !AppHelper.valid_url?(App::Persistence[:api_url])
      @settings ||= SettingsController.new
      @settings.parent_controller = BeerTapController.controller
      @settings_navigation = UINavigationController.alloc.initWithRootViewController(@settings)
      BeerTapController.controller.presentModalViewController(@settings_navigation, animated:false)
    else
      AppHelper.reload_settings
    end

    true
  end

  def setup_faye
    puts ""
    puts "AppDelegate > setup_faye"
    @faye_listener = nil
    @faye_listener = FayeListener.alloc.initWithNavigationController(@navigation_controller)
    @faye_listener.listen
  end
end