class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    @beer_tap_controller = BeerTapController.alloc.init
    @navigation_controller = UINavigationController.alloc.initWithRootViewController(@beer_tap_controller)

    # Setup NotificationController
    @notification_controller = NotificationController.alloc.initWithNavigationController(@navigation_controller)
    @notification_controller.listen

    @window.rootViewController = @navigation_controller
    load_settings

    true
  end

  def load_settings
    App::Persistence[:api_url] = "http://bender.dev"

    BW::HTTP.get("#{App::Persistence[:api_url]}/admin/settings.json") do |response|
      json = p response.body.to_str

      settings = BW::JSON.parse json
      settings.symbolize_keys!
puts "#{settings}"
      settings.each { |key,val| App::Persistence[key] = val }

      # Setup Faye listener
      @faye = FayeListener.alloc.initWithNavigationController(@navigation_controller)
      @faye.listen

      @window.makeKeyAndVisible
    end
  end
end