class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @main_controller = MainController.new
    @window.rootViewController = @main_controller
    @window.makeKeyAndVisible

    if App::Persistence[:api_url].blank? || !AppHelper.valid_url?(App::Persistence[:api_url])
      @settings ||= SettingsController.new
      @settings.main_controller = @main_controller
      @settings_navigation = UINavigationController.alloc.initWithRootViewController(@settings)
      @settings_navigation.modalPresentationStyle = UIModalPresentationFormSheet
      @main_controller.presentModalViewController(@settings_navigation, animated:false)
    else
      @main_controller.reload_settings
    end

    true
  end

  def applicationWillResignActive(application)
    # Sent when the application is about to move from active to inactive state.
    # This can occur for certain types of temporary interruptions (such as an incoming
    # phone call or SMS message) or when the user quits the application and it begins the
    # transition to the background state.
    # Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates.
    # Games should use this method to pause the game.
  end

  def applicationDidEnterBackground(application)
    # Use this method to release shared resources, save user data, invalidate timers, and store enough
    # application state information to restore your application to its current state in case it is terminated later. 
    # If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  end

  def applicationWillEnterForeground(application)
    # Called as part of the transition from the background to the inactive state.
    # Here you can undo many of the changes made on entering the background.
  end

  def applicationDidBecomeActive(application)
    # Restart any tasks that were paused (or not yet started) while the application was inactive.
    # If the application was previously in the background, optionally refresh the user interface.
  end

  def applicationWillTerminate(application)
    # Called when the application is about to terminate.
    # Save data if appropriate.
    # See also applicationDidEnterBackground:.
  end

  def supportedInterfaceOrientationsForWindow(window)
    UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown
  end
end
