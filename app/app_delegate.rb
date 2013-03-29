class AppDelegate
  attr_accessor :main_controller

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    StyleController.apply_style

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @main_controller = MainController.new
    @window.rootViewController = @main_controller
    @window.makeKeyAndVisible

    if App::Persistence[:api_url].blank? || !AppHelper.valid_url?(App::Persistence[:api_url])
      show_settings
    else
      App.notification_center.post "SettingsReloadedNotification"
    end

    App.notification_center.observe "FayeConnectNotification" do |notification|
      hide_model if @modal_view
    end

    App.notification_center.observe "FayeDisconnectNotification" do |notification|
      puts "In delegate faye disconnect"
      show_modal unless @modal_view
    end

    App.notification_center.observe "FayeCouldNotConnectNotification" do |notification|
      hide_model if @modal_view
      App.alert("Could not connect to Bender. Please confirm your settings.")
      show_settings
    end

    true
  end

  def show_settings
    @settings ||= SettingsController.new
    @settings.parent_controller = @main_controller
    @settings_navigation = UINavigationController.alloc.initWithRootViewController(@settings)
    @settings_navigation.modalPresentationStyle = UIModalPresentationFormSheet
    @main_controller.presentModalViewController(@settings_navigation, animated:false)
  end

  def show_modal
    @modal_view = UIView.alloc.initWithFrame(@window.bounds)
    @modal_view.opaque = false
    @modal_view.backgroundColor = UIColor.blackColor.colorWithAlphaComponent(0.75)

    label = UILabel.new
    label.frame = @window.bounds
    label.text = "Disconnected from Bender. Attemping to reconnect..."
    label.textColor = UIColor.whiteColor
    label.backgroundColor = UIColor.clearColor
    label.opaque = false
    label.textAlignment = UITextAlignmentCenter
    @modal_view << label

    button_image = "button".uiimage.resizableImageWithCapInsets(UIEdgeInsetsMake(22, 7, 23, 7))
    button_image_selected = "button-selected".uiimage.resizableImageWithCapInsets(UIEdgeInsetsMake(22, 7, 23, 7))

    button = UIButton.custom
    button.frame = [[253, 540], [262, 44]]
    button.setBackgroundImage(button_image, forState: UIControlStateNormal)
    button.setBackgroundImage(button_image_selected, forState: UIControlStateHighlighted)
    button.setTitle("Settings", forState: UIControlStateNormal)
    button.titleLabel.font = :bold.uifont(18)
    button.titleLabel.shadowColor = "#111".uicolor
    button.titleLabel.shadowOffset = [0, -2]

    button.on(:touch) do
      hide_model if @modal_view
      show_settings
    end

    @modal_view << button
    @window << @modal_view
  end

  def hide_model
    @modal_view.removeFromSuperview if @modal_view
    @modal_view = nil
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
    @main_controller.faye_handler.disconnect
  end

  def applicationWillEnterForeground(application)
    # Called as part of the transition from the background to the inactive state.
    # Here you can undo many of the changes made on entering the background.
    @main_controller.faye_handler.connect
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
