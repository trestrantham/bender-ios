class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    @keg_controller = KegController.alloc.initWithNibName(nil, bundle:nil)
    @navigation_controller = UINavigationController.alloc.initWithRootViewController(@keg_controller)

    @window.rootViewController = @navigation_controller
    @window.makeKeyAndVisible
    true
  end
end