class FayeHandler
  attr_accessor :connected

  MAX_RETRY = 18
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

    @settings_observer = App.notification_center.observe "SettingsReloadedNotification" do |notification|
      reconnect
    end

    @disconnect_observer = App.notification_center.observe "FayeDisconnectNotification" do |notification|
      connect if disconnected && @retry_count == 0
    end

    # @overlay = MTStatusBarOverlay.sharedInstance
    # @overlay.delegate = self
    # @overlay.animation = MTStatusBarOverlayAnimationFallDown
    # @overlay.historyEnabled = true
    # @overlay.detailViewMode = MTDetailViewModeHistory

    self
  end

  def connect
    puts ""
    puts "FayeHandler > connect"
    @overlay.postMessage "FayeHandler > connect" if @overlay

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
    @overlay.postMessage "FayeHandler > try_connect > retry_count: #{@retry_count}" if @overlay

    @faye.connectToServer if @faye
    @retry_count = @retry_count + 1

    EM.add_timer RETRY_WAIT do
      try_connect if disconnected && @retry_count <= MAX_RETRY
    end

    App.notification_center.post "FayeCouldNotConnectNotification" if @retry_count == MAX_RETRY
  end

  def reconnect
    puts ""
    puts "FayeHandler > reconnect"
    @overlay.postMessage "FayeHandler > reconnect" if @overlay

    disconnect
    setup
    connect
  end

  def disconnect
    puts ""
    puts "FayeHandler > disconnect"
    @overlay.postMessage "FayeHandler > disconnect" if @overlay

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
    @overlay.postMessage "Faye Client Error: #{error}" if @overlay
  end

  def messageReceived(message, channel:channel)
    puts "FayeHandler > messageReceived: #{message}"
    App.notification_center.post("PourUpdateNotification", nil, message) if channel.to_s == "/pour/update"
    App.notification_center.post("PourUpdateNotification", nil, message) if channel.to_s == "/pour/complete"
  end

  def connectedToServer
    puts ""
    puts "FayeHandler > connectedToServer"
    puts "FayeHandler: listening on #{App::Persistence[:faye_url]}..."

    @connected = true
    @retry_count = 0
    @overlay.postMessage "Connected" if @overlay

    App.notification_center.post "FayeConnectNotification"
  end

  def disconnectedFromServer
    puts ""
    puts "FayeHandler > disconnectedFromServer"

    @connected = false
    @overlay.postMessage "Disconnected" if @overlay

    App.notification_center.post "FayeDisconnectNotification"
  end
end
