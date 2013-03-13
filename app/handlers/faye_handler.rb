class FayeHandler
  attr_accessor :connected

  MAX_RETRY = 12
  RETRY_WAIT = 5

  def setup
    puts ""
    puts "FayeHandler > setup"

    @connected = false
    @faye = nil
    @retry_count = 0

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

    @settings_observer = App.notification_center.observe "SettingsChangedNotification" do |notification|
      reconnect
    end

    self
  end

  def connect
    puts ""
    puts "FayeHandler > connect"

    setup unless @faye

    if @faye
      try_connect
    else
      puts "FayeHandler: Failed!"
      App.alert("There's a problem with the Faye URL.")
    end
  end

  def try_connect
    puts ""
    puts "FayeHandler > try_connect > retry_count: #{@retry_count}"

    @faye.connectToServer if @faye
    @retry_count = @retry_count + 1

    EM.add_timer RETRY_WAIT do
      try_connect if disconnected && @retry_count <= MAX_RETRY
    end

    # send "could not connect" notification if @retry_count == MAX_RETRY
  end

  def reconnect
    puts ""
    puts "FayeHandler > reconnect"

    disconnect
    setup
    connect
  end

  def disconnect
    puts ""
    puts "FayeHandler > disconnect"

    @faye.disconnectFromServer if @faye && @connected
    @faye = nil
  end

  def disconnected
    !@connected
  end

  #pragma mark -
  #pragma mark FayeObjc delegate

  def fayeClientError(error)
    puts "Faye Client Error: #{error}"
  end

  def messageReceived(message, channel:channel)
    App.notification_center.post("PourUpdateNotification", nil, message) if channel.to_s == "/pour/update"
    App.notification_center.post("PourUpdateNotification", nil, message) if channel.to_s == "/pour/complete"
  end

  def connectedToServer
    puts ""
    puts "FayeHandler > connectedToServer"
    puts "FayeHandler: listening on #{App::Persistence[:faye_url]}..."

    App.notification_center.post "FayeConnectNotification"

    @connected = true
    @retry_count = 0
  end

  def disconnectedFromServer
    puts ""
    puts "FayeHandler > disconnectedToServer"

    App.notification_center.post "FayeDisconnectNotification"
    @connected = false
  end
end
