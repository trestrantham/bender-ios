class FayeListener

  @faye = nil
  @connected = nil
  @navigation_controller = nil

  attr_accessor :faye, :connected

  def initWithNavigationController(navigation_controller)
    self.init

    @navigation_controller = navigation_controller
    @connected = false
    @faye = FayeClient.alloc.initWithURLString(App::Persistence[:faye_url], channel: nil)
    @faye.subscribeToChannel "/pour/update"
    @faye.subscribeToChannel "/pour/complete"
    @faye.delegate = self

    self
  end

  def listen
    puts "FayeListener: listening..."
    @faye.connectToServer
  end

  #pragma mark -
  #pragma mark FayeObjc delegate

  def fayeClientError(error)
    puts "Faye Client Error: #{error}"
  end

  def messageReceived(message, channel:channel)
    puts ""
    puts "Message received: #{message}"
    puts ""
    puts "Message received on channel: #{channel}"
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