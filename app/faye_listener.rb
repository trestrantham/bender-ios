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
    @faye.subscribeToChannel "/user"
    @faye.delegate = self
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
    puts "Message received: #{message}"
    puts "Message received on channel: #{channel}"
    case channel
    when "/pour/update"
      then App.notification_center.postNotificationName("PourUpdateNotification", object: nil, userInfo: message)
    end
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