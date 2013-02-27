class FayeListener
  attr_accessor :connected

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
    puts ""
    puts "FayeListener > listen"

    if @faye
      try_connect
    else
      puts "FayeListener: Failed!"
      App.alert("There's a problem with the Faye URL.")
    end
  end

  def try_connect
    puts ""
    puts "FayeListener > try_connect"

    @faye.connectToServer

    # Retry every 5 seconds until a Faye connection is established
    EM.add_timer 5 do
      if !@connected
        puts "FayeListener > try_connect > retrying Faye connection..."
        try_connect
      end
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
    puts ""
    puts "FayeListener > connectedToServer"
    puts "FayeListener: listening on #{App::Persistence[:faye_url]}..."

    App.notification_center.postNotificationName("FayeConnectNotification", object: nil, userInfo: nil)
    @connected = true
  end

  def disconnectedFromServer
    puts ""
    puts "FayeListener > disconnectedToServer"

    App.notification_center.postNotificationName("FayeDisconnectNotification", object: nil, userInfo: nil)
    @connected = false
  end
end