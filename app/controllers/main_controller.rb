class MainController < UIViewController
  BEER_LIST_WIDTH = 428
  USER_LIST_WIDTH = 340
  LIST_HEIGHT = 753
  PADDING = 20

  attr_accessor :faye_handler # TODO(Tres): change to class method

  def viewDidLoad
    puts ""
    puts "MainController > viewDidLoad"

    super

    @current_pour = nil
    @current_user_id = nil
    @current_mode = :normal

    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    self.view.backgroundColor = "#444".uicolor

    # Setup views
    @beers_view = setup_beers_view
    @users_view = setup_users_view
    @context_view = setup_context_view

    self.view << @beers_view
    self.view << @users_view
    self.view << @context_view

    setup_child_controllers
    setup_handlers
    setup_observers
  end

  def viewDidUnload
    App.notification_center.unobserve @pour_update_observer
    App.notification_center.unobserve @settings_observer
    App.notification_center.unobserve @settings_changed_observer
    App.notification_center.unobserve @user_timeout_observer
    App.notification_center.unobserve @user_update_observer
    App.notification_center.unobserve @pour_edit_observer

    @beers_controller = nil
    @users_controller = nil
    @context_controller = nil
    @beers_view = nil
    @users_view = nil
    @context_view = nil
    @pour_update_observer = nil
    @settings_observer = nil
    @settings_changed_observer = nil
    @user_timeout_observer = nil
    @user_update_observer = nil
    @pour_edit_observer = nil
  end

# Setup

  def setup_beers_view
    beers_view = UIView.alloc.initWithFrame([[0, 0], [BEER_LIST_WIDTH, LIST_HEIGHT]])
    highlight_top = UIView.alloc.initWithFrame([[0, 0], [BEER_LIST_WIDTH - 1, 1]])
    highlight_top.backgroundColor = "#666".uicolor
    shadow_bottom = UIView.alloc.initWithFrame([[0, LIST_HEIGHT - 1], [BEER_LIST_WIDTH - 1, 1]])
    shadow_bottom.backgroundColor = :black.uicolor
    y_line = UIView.alloc.initWithFrame([[BEER_LIST_WIDTH - 1, 0], [1, LIST_HEIGHT]])
    y_line.backgroundColor = :black.uicolor
    highlight_bottom = UIView.alloc.initWithFrame([[PADDING, 
                                                    LIST_HEIGHT - PADDING], 
                                                   [BEER_LIST_WIDTH - PADDING * 2, 
                                                    1]])
    highlight_bottom.backgroundColor = "#666".uicolor
    beers_view << highlight_top
    beers_view << shadow_bottom
    beers_view << y_line
    beers_view << highlight_bottom

    beers_view
  end

  def setup_users_view
    users_view = UIView.alloc.initWithFrame([[BEER_LIST_WIDTH, 0], [USER_LIST_WIDTH, LIST_HEIGHT]])
    users_view = UIView.alloc.initWithFrame([[BEER_LIST_WIDTH, 0], [USER_LIST_WIDTH, LIST_HEIGHT]])
    highlight_top = UIView.alloc.initWithFrame([[0, 0], [BEER_LIST_WIDTH, 1]])
    highlight_top.backgroundColor = "#666".uicolor
    shadow_bottom = UIView.alloc.initWithFrame([[0, LIST_HEIGHT - 1], [USER_LIST_WIDTH, 1]])
    shadow_bottom.backgroundColor = :black.uicolor
    y_line = UIView.alloc.initWithFrame([[0, 0], [1, LIST_HEIGHT - 1]])
    y_line.backgroundColor = "#666".uicolor
    highlight_bottom = UIView.alloc.initWithFrame([[PADDING,
                                                    # LIST_HEIGHT - PADDING * 2 - 44], # Allow for 'add user' button
                                                    LIST_HEIGHT - PADDING],
                                                   [USER_LIST_WIDTH - PADDING * 2,
                                                    1]])
    highlight_bottom.backgroundColor = "#666".uicolor
    users_view << highlight_bottom
    users_view << highlight_top
    users_view << shadow_bottom
    users_view << y_line

    users_view
  end

  def setup_context_view
    context_view = UIView.alloc.initWithFrame([[0, LIST_HEIGHT], [768, 251]])
    context_view.backgroundColor = "#444".uicolor
    highlight_top = UIView.alloc.initWithFrame([[0, 0], [BEER_LIST_WIDTH + USER_LIST_WIDTH, 1]])
    highlight_top.backgroundColor = "#666".uicolor
    context_view << highlight_top

    context_view
  end

  def setup_child_controllers
    beer_list_controller = BeerListController.new
    @beers_controller = UINavigationController.alloc.initWithRootViewController(beer_list_controller)
    self.addChildViewController(@beers_controller)
    @beers_controller.didMoveToParentViewController(self)
    @beers_controller.view.frame = [[@beers_view.bounds.origin.x + PADDING,
                                     @beers_view.bounds.origin.y + PADDING],
                                    [@beers_view.bounds.size.width - PADDING * 2,
                                     @beers_view.bounds.size.height - PADDING * 2]]

    user_list_controller = UserListController.new
    @users_controller = UINavigationController.alloc.initWithRootViewController(user_list_controller)
    self.addChildViewController(@users_controller)
    @users_controller.didMoveToParentViewController(self)
    @users_controller.view.frame = [[@users_view.bounds.origin.x + PADDING,
                                     @users_view.bounds.origin.y + PADDING],
                                    [@users_view.bounds.size.width - PADDING * 2,
                                     @users_view.bounds.size.height - PADDING * 2]]
                                     # @users_view.bounds.size.height - PADDING * 3 - 44]] # Allow for 'add user' button

    user_list_controller.navigationItem.rightBarButtonItem ||= UIBarButtonItem.add do
      @add_user_controller ||= AddUserController.new
      @add_user_controller.parent_controller = self
      @add_user_navigation = UINavigationController.alloc.initWithRootViewController(@add_user_controller)
      @add_user_navigation.modalPresentationStyle = UIModalPresentationFormSheet
      presentModalViewController(@add_user_navigation, animated: true)
    end

    @context_controller = ContextController.new
    self.addChildViewController(@context_controller)
    @context_controller.didMoveToParentViewController(self)
    @context_controller.view.frame = @context_view.bounds

    settings_button = UIButton.custom
    settings_button.frame = [[BEER_LIST_WIDTH + USER_LIST_WIDTH - 30, 225], [20, 22]]
    settings_button.setBackgroundImage("settings".uiimage, forState: UIControlStateNormal)

    settings_button.on(:touch) do
      @settings_controller ||= SettingsController.new
      @settings_controller.parent_controller = self
      @settings_navigation = UINavigationController.alloc.initWithRootViewController(@settings_controller)
      @settings_navigation.modalPresentationStyle = UIModalPresentationFormSheet
      presentModalViewController(@settings_navigation, animated: true)
    end

    @beers_view << @beers_controller.view
    @users_view << @users_controller.view
    @context_view << @context_controller.view
    @context_view << settings_button # Must add to view after context_controller in order to stay in foreground
  end

  def setup_handlers
    @faye_handler = FayeHandler.new
    @faye_handler.setup

    @pour_handler = PourHandler.new
    @pour_handler.setup

    @settings_handler = SettingsHandler.new
  end

  def setup_observers
    @pour_update_observer = App.notification_center.observe "PourUpdateNotification" do |notification|
      pour_update(notification.userInfo.symbolize_keys) unless notification.userInfo.nil?
    end

    @pour_timeout_observer = App.notification_center.observe "PourTimeoutNotification" do |_|
      end_pour
    end

    @user_update_observer = App.notification_center.observe "UserUpdatedNotification" do |notification|
      user_update(notification.userInfo.symbolize_keys) unless notification.userInfo.nil?
    end

    @user_timeout_observer = App.notification_center.observe "UserTimeoutNotification" do |notification|
      reset_user(notification.userInfo.symbolize_keys) unless notification.userInfo.nil? || @current_mode == :edit
    end

    @settings_observer = App.notification_center.observe "SettingsReloadedNotification" do |_|
      reload_data
    end

    @settings_changed_observer = App.notification_center.observe "SettingsChangedNotification" do |_|
      @settings_handler.reload_settings
    end

    @pour_edit_observer = App.notification_center.observe "PourEditNotification" do |notification|
      @current_mode = :edit
      pour_edit(notification.userInfo.symbolize_keys) unless notification.userInfo.nil?
    end

    @pour_edit_saved_observer = App.notification_center.observe "PourEditSavedNotification" do |_|
      pour_edit_save
      @current_mode = :normal
    end

    @pour_edit_canceled_observer = App.notification_center.observe "PourEditCanceledNotification" do |_|
      pour_edit_cancel
      @current_mode = :normal
    end
  end

# Handle events

  def reload_data
    puts ""
    puts "MainController > reload_data"

    @beers_controller.popToRootViewControllerAnimated(false)
    @beers_controller.topViewController.load_data

    @users_controller.popToRootViewControllerAnimated(false)
    @users_controller.topViewController.load_data
  end

  def pour_update(pour)
    puts ""
    puts "MainController > pour_update"

    @current_pour = pour
    @current_user_id = pour.fetch(:user_id, 0).to_i if @current_user_id.nil?

    @pour_handler.pour_update(@current_pour, @current_user_id)

    @beers_controller.popToRootViewControllerAnimated(false)
    @beers_controller.topViewController.select_beer(@current_pour)

    @users_controller.popToRootViewControllerAnimated(false)
    @users_controller.topViewController.update_user(@current_user_id)
  end

  def pour_edit(pour)
    puts ""
    puts "MainController > pour_edit: current_mode = #{@current_mode}"

    @current_pour = pour
    @current_user_id = pour.fetch(:user_id, 0).to_i

    @beers_controller.popToRootViewControllerAnimated(false)
    @beers_controller.topViewController.select_beer(@current_pour, @current_mode)

    @users_controller.popToRootViewControllerAnimated(false)
    @users_controller.topViewController.update_user(@current_user_id, @current_mode)
  end

  def pour_edit_save
    puts ""
    puts "MainController > pour_edit_save: current_user_id = #{@current_user_id} | current_pour[:id] = #{@current_pour[:id]}"

    if !@current_user_id.nil? && @current_pour && @current_pour.has_key?(:id)
      puts "MainController > pour_edit_save > updating user"
      @pour_handler.update_pour_user(@current_pour[:id], @current_user_id)
    end
  end

  def pour_edit_cancel
    puts ""
    puts "MainController > pour_edit_cancel"

    if !@current_user_id.nil? && @current_pour && @current_pour.has_key?(:id)
      reset_user({ id: @current_user_id })
      end_pour
    end
  end

  def user_update(user)
    puts ""
    puts "MainController > user_update"

    return unless user.has_key?(:id)

    @current_user_id = user[:id].to_i 
    puts "MainController > user_update: setting current_user_id to #{@current_user_id}"

    unless @current_mode == :edit
      @pour_handler.user_update(user)

      unless @current_pour.nil? || user[:id].to_i == @current_pour.fetch(:user_id, 0).to_i
        @pour_handler.update_pour_user(@current_pour[:id], user[:id])
      end
    end
  end

  def reset_beer
    puts ""
    puts "MainController > reset_beer"

    # @beers_controller.popToRootViewControllerAnimated(false)
    # @beers_controller.topViewController.reset
  end

  def reset_user(user)
    puts ""
    puts "MainController > reset_user"

    @users_controller.popToRootViewControllerAnimated(false)
    @users_controller.topViewController.reset_user(user.fetch(:id, 0))

    if @current_user_id == user.fetch(:id, 0).to_i
      puts "MainController > reset_user: resetting current_user_id"
      @current_user_id = nil
    end
  end

  def end_pour
    puts ""
    puts "MainController > end_pour"

    @beers_controller.popToRootViewControllerAnimated(false)
    @beers_controller.topViewController.reset_beer

    @current_pour = nil
  end

  def supportedInterfaceOrientations
    UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown
  end
end
