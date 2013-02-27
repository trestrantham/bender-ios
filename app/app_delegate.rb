class AppDelegate
  attr_accessor :faye_listener

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    @navigation_controller = MainController.alloc.initWithRootViewController(BeerTapController.controller)
    @window.rootViewController = @navigation_controller
    @window.makeKeyAndVisible

    # Setup NotificationController
    @notification_controller = NotificationController.alloc.initWithNavigationController(@navigation_controller)
    @notification_controller.listen

    @faye_listener = nil

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

    if @faye_listener.nil? || !@faye_listener.connected
      puts "AppDelegate > setup_faye > restarting"
      @faye_listener = nil
      @faye_listener = FayeListener.alloc.initWithNavigationController(@navigation_controller)
      @faye_listener.listen
    else
      puts "AppDelegate > setup_faye > still active"
    end
  end
end