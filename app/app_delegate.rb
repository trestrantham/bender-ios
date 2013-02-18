class AppDelegate
	attr_accessor :navigation_controller

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    setup_config

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    @beer_tap_controller = BeerTapController.alloc.init
    @navigation_controller = UINavigationController.alloc.initWithRootViewController(@beer_tap_controller)

    # Setup Faye listener
		@faye = FayeListener.alloc.initWithNavigationController(@navigation_controller)
		@faye.listen

    # Setup NotificationController
    @notification_controller = NotificationController.alloc.initWithNavigationController(@navigation_controller)
    @notification_controller.listen

    @window.rootViewController = @navigation_controller
    @window.makeKeyAndVisible
    true
  end

  # TODO(Tres): Refactor
  def setup_config
    App::Persistence[:faye_url] = "ws://localhost:9292/faye"
    App::Persistence[:api_url] = "http://bender.dev"
  end

end