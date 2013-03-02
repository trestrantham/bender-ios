class PourHandler
  def initWithMainController(main_controller)
    self.init
    @main_controller = main_controller
    self
  end

  def listen
    puts ""
    puts "PourEventHandler > listen"
    App.notification_center.addObserver(self, selector:"pour_updated:", name:"PourUpdateNotification", object:nil)
    App.notification_center.addObserver(self, selector:"pour_updated:", name:"PourCompleteNotification", object:nil)
    App.notification_center.addObserver(self, selector:"user_updated:", name:"UserUpdateNotification", object:nil)
    App.notification_center.addObserver(self, selector:"user_updated:", name:"UserUpdateNotification", object:nil)
  end

  def pour_updated(notification)
    puts ""
    puts "PourEventHandler > pour_updated"

    pour = notification.userInfo.nil? ? {} : notification.userInfo.symbolize_keys
    pour_controller = nil
    
    user_id = if pour.has_key?(:user_id) && pour[:user_id].to_i > 0
                pour[:user_id].to_i
              elsif !App::Persistence[:current_user].blank? && App::Persistence[:current_user].has_key?(:id)
                App::Persistence[:current_user][:id].to_i
              else
                0
              end

    #if @main_controller.visibleViewController.class.to_s != "PourController"
    # pour_controller = PourController.alloc.initWithBeerTap(pour[:beer_tap_id].to_i, user: user_id)
    # @main_controller.popToRootViewControllerAnimated false
    # @main_controller.pushViewController(pour_controller, animated: true)
    #else
    # pour_controller = @main_controller.visibleViewController
    #end

    if pour_controller.nil?
      puts "!!! ERROR: No pour_controller in PourEventHandler > pour_updated"
    else
      pour_controller.update_pour(pour)
    end
  end

  # Set the current user as active for the user_timeout period.
  # Calling this repeatedly (as done during a pour event) will keep the user 'alive'.
  def user_updated(notification)
    puts ""
    puts "PourEventHandler > user_updated"

    current_user = App::Persistence[:current_user].nil? ? {} : App::Persistence[:current_user].dup # Duping to get NSMutable
    current_user = notification.userInfo.symbolize_keys unless notification.userInfo.nil?
    current_user[:now] = "#{Time.now}"
    App::Persistence[:current_user] = current_user

    # Wait for the user_timeout and see if the user is still active
    EM.add_timer App::Persistence[:user_timeout].to_i do
puts "App::Persistence[:current_user][:now].to_s: #{App::Persistence[:current_user][:now].to_s}"
      
      now_time


      user_now = AppHelper.parse_date_string(App::Persistence[:current_user][:now].to_s, "yyyy-MM-dd HH:mm:ss z") 
      if !App::Persistence[:current_user].blank? && (user_now + App::Persistence[:user_timeout].to_i) <= Time.now
        puts "PourEventHandler > user_updated > USER TIMED OUT"
        App::Persistence[:current_user] = nil
      end
    end
  end
end