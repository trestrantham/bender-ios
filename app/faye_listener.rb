class FayeListener
  def initWithNavigationController(navigation_controller)
    self.init

    @navigation_controller = navigation_controller
    @connected = false

    if App::Persistence[:faye_url].blank?
      App.alert("Faye URL is required!")

    elsif !AppHelper.valid_url?(App::Persistence[:faye_url])
      App.alert("Invalid Faye URL.")
    else
      @faye = FayeClient.alloc.initWithURLString(App::Persistence[:faye_url], channel: nil)
      @faye.subscribeToChannel "/pour/update"
      @faye.subscribeToChannel "/pour/complete"
      @faye.delegate = self
    end

    self
  end

  def listen
    if @faye
      puts "FayeListener: listening on #{App::Persistence[:faye_url]}..."
      @faye.connectToServer
    else
      puts "FayeListener: Failed!"
      App.alert("There's a problem with the Faye URL.")
    end
  end

  #pragma mark -
  #pragma mark FayeObjc delegate

  def fayeClientError(error)
    puts "Faye Client Error: #{error}"
  end

  def messageReceived(message, channel:channel)
    App.notification_center.postNotificationName("PourUpdateNotification", object: nil, userInfo: message) if channel.to_s == "/pour/update"
    App.notification_center.postNotificationName("PourCompleteNotification", object: nil, userInfo: message) if channel.to_s == "/pour/complete"
  end

  def connectedToServer
    puts "Connected"
    @connected = true
  end

  def disconnectedFromServer
    puts "Disconnected"
    @connected = false
    @faye.connectToServer
  end
end