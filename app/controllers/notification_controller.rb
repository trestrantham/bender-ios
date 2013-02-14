class NotificationController
	def initWithNavigationController(navigation_controller)
		@navigation_controller = navigation_controller
	end

	def listen
		App.notification_center.addObserver(self, selector:"pour_updated:", name:"PourUpdateNotification", object:nil)
		App.notification_center.addObserver(self, selector:"user_updated:", name:"UserUpdateNotification", object:nil)
  end

  def pour_updated(notification)
  	puts "EventController > pour_updated"

  	pour = notification.userInfo
  	pour_controller = nil

		if @navigation_controller.visibleViewController.class.to_s != "PourController"
			puts "EventController > pour_updated > pushing PourController"
			pour_controller = PourController.alloc.initWithTap(pour["beer_tap_id"].to_i, user: pour["user_id"].to_i)
			@navigation_controller.popToRootViewControllerAnimated false
			@navigation_controller.pushViewController(pour_controller, animated: true)
		else
			puts "EventController > pour_updated > PourController is active"
			pour_controller = @navigation_controller.visibleViewController
		end

		if pour_controller == nil
			puts "!!! ERROR: No pour_controller in NotificationController > pour_updated"
		else
			pour_controller.update_pour(pour)
		end
  end

  def user_updated
  	puts "EventController > user_updated"
  end
end