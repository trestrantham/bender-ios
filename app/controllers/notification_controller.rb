class NotificationController
	USER_TIMEOUT = 10

	def initWithNavigationController(navigation_controller)
		self.init
		@navigation_controller = navigation_controller
		self
	end

	def listen
		App.notification_center.addObserver(self, selector:"pour_started:", name:"PourStartNotification", object:nil)
		App.notification_center.addObserver(self, selector:"pour_updated:", name:"PourUpdateNotification", object:nil)
		App.notification_center.addObserver(self, selector:"pour_completed:", name:"PourCompleteNotification", object:nil)
		App.notification_center.addObserver(self, selector:"user_updated:", name:"UserUpdateNotification", object:nil)
  end

	def pour_started(notification)
		puts ''
		puts "NotificationController > pour_started"
	end

	def pour_completed(notification)
		puts ''
		puts "NotificationController > pour_completed"
	end

  def pour_updated(notification)
		puts ''
		puts "NotificationController > pour_updated"

		user_info = notification.userInfo.nil? ? nil : notification.userInfo.dup
		pour = user_info.nil? ? {} : user_info.symbolize!
		pour_controller = nil

		user_id = if pour.has_key?(:user_id) && pour[:user_id].to_i > 0
								pour[:user_id].to_i
							elsif !App::Persistence[:current_user].nil? && App::Persistence[:current_user].has_key?(:id)
								App::Persistence[:current_user][:id].to_i
							else
								0
							end

		if @navigation_controller.visibleViewController.class.to_s != "PourController"
			puts "NotificationController > pour_updated > pushing PourController"
			pour_controller = PourController.alloc.initWithBeerTap(pour[:beer_tap_id].to_i, user: user_id)
			@navigation_controller.popToRootViewControllerAnimated false
			@navigation_controller.pushViewController(pour_controller, animated: true)
		else
			puts "NotificationController > pour_updated > PourController is active"
			pour_controller = @navigation_controller.visibleViewController
		end

		if pour_controller == nil
			puts "!!! ERROR: No pour_controller in NotificationController > pour_updated"
		else
			pour_controller.update_pour(pour)
		end
  end

  def user_updated(notification)
		puts ''
		puts "NotificationController > user_updated"

		user_info = notification.userInfo.nil? ? nil : notification.userInfo.dup # Duping to get NSMutable

		current_user = App::Persistence[:current_user].nil? ? {} : App::Persistence[:current_user].dup # Duping to get NSMutable
		current_user = user_info.symbolize! unless user_info.nil?
		current_user[:now] = "#{Time.now}"

		App::Persistence[:current_user] = current_user

		EM.add_timer USER_TIMEOUT do
			if (AppHelper.parse_date_string(App::Persistence[:current_user][:now].to_s, "yyyy-MM-dd HH:mm:ss z") + USER_TIMEOUT) <= Time.now
				puts "NotificationController > user_updated > USER TIMED OUT"
				App::Persistence[:current_user] = nil
			else
				puts "NotificationController > user_updated > USER STILL ACTIVE"
			end
		end
  end
end