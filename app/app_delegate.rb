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

    @window.rootViewController = @navigation_controller
    @window.makeKeyAndVisible
    true
  end

  def setup_config
    App::Persistence[:faye_url] = "ws://localhost:9292/faye"
    #App::Persistence[:faye_channel] = "/testing"
    App::Persistence[:api_url] = "http://bender.dev" 
  end

end

module BubbleWrap
  module App
    module_function

    def current_user
      App::Persistence[:current_user]
    end

    def current_user=(user)
      App::Persistence[:current_user] = user
    end
  end
end