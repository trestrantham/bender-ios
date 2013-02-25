class NotificationController
	def initWithNavigationController(navigation_controller)
		self.init
		@navigation_controller = navigation_controller
		self
	end

	def listen
		puts ""
		puts "NotificationController > listen"
		App.notification_center.addObserver(self, selector:"pour_updated:", name:"PourUpdateNotification", object:nil)
		App.notification_center.addObserver(self, selector:"pour_completed:", name:"PourCompleteNotification", object:nil)
		App.notification_center.addObserver(self, selector:"user_updated:", name:"UserUpdateNotification", object:nil)
  end

	def pour_completed(notification)
		puts ''
		puts "NotificationController > pour_completed"
		pour_updated(notification)
	end

  def pour_updated(notification)
		puts ''
		puts "NotificationController > pour_updated"

		pour = notification.userInfo.nil? ? {} : notification.userInfo.symbolize_keys
		pour_controller = nil

		user_id = if pour.has_key?(:user_id) && pour[:user_id].to_i > 0
								pour[:user_id].to_i
							elsif !App::Persistence[:current_user].nil? && App::Persistence[:current_user].has_key?(:id)
								App::Persistence[:current_user][:id].to_i
							else
								0
							end

		if @navigation_controller.visibleViewController.class.to_s != "PourController"
# puts "NotificationController > pour_updated > pushing PourController"
			pour_controller = PourController.alloc.initWithBeerTap(pour[:beer_tap_id].to_i, user: user_id)
			@navigation_controller.popToRootViewControllerAnimated false
			@navigation_controller.pushViewController(pour_controller, animated: true)
		else
# puts "NotificationController > pour_updated > PourController is active"
			pour_controller = @navigation_controller.visibleViewController
		end

		if pour_controller == nil
# puts "!!! ERROR: No pour_controller in NotificationController > pour_updated"
		else
			pour_controller.update_pour(pour)
		end
  end

  def user_updated(notification)
		puts ''
		puts "NotificationController > user_updated"

		current_user = App::Persistence[:current_user].nil? ? {} : App::Persistence[:current_user].dup # Duping to get NSMutable
		current_user = notification.userInfo.symbolize_keys unless notification.userInfo.nil?
		current_user[:now] = "#{Time.now}"
		App::Persistence[:current_user] = current_user
# puts "NotificationController > user_updated > App::Persistence[:current_user]: #{App::Persistence[:current_user]}"
		EM.add_timer App::Persistence[:user_timeout].to_i do
			# TODO(Tres): Flip flop
			if App::Persistence[:current_user] && (AppHelper.parse_date_string(App::Persistence[:current_user][:now].to_s, "yyyy-MM-dd HH:mm:ss z") + App::Persistence[:user_timeout].to_i) <= Time.now
				puts "NotificationController > user_updated > USER TIMED OUT"
				App::Persistence[:current_user] = nil
			else
# puts "NotificationController > user_updated > USER STILL ACTIVE > App::Persistence[:current_user]: #{App::Persistence[:current_user]}"
			end
		end
  end
end