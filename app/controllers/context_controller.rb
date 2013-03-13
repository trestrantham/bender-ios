class ContextController < UIViewController
  attr_accessor :pour_controller

  SCROLL_PAGE_WIDTH = 728
  SCROLL_PAGE_HEIGHT = 191
  NUM_PAGES = 3

  def viewDidLoad
    @scroll_view = UIScrollView.alloc.initWithFrame([[0, 0], [SCROLL_PAGE_WIDTH, SCROLL_PAGE_HEIGHT]])
    @scroll_view.delegate = self
    @scroll_view.contentSize = [SCROLL_PAGE_WIDTH * NUM_PAGES, SCROLL_PAGE_HEIGHT]
    @scroll_view.backgroundColor = "#333".uicolor
    @scroll_view.scrollsToTop = false
    @scroll_view.bounces = false
    @scroll_view.pagingEnabled = true
    @scroll_view.showsHorizontalScrollIndicator = false
    @scroll_view.showsVerticalScrollIndicator = false

    @scroll_view.layer.masksToBounds = true
    @scroll_view.layer.borderColor = :black.uicolor.CGColor
    @scroll_view.layer.borderWidth = 1

    @page_control = UIPageControl.alloc.init
    @page_control.frame = [[0, SCROLL_PAGE_HEIGHT + 15], [768, 10]] 
    @page_control.numberOfPages = NUM_PAGES 
    @page_control.currentPage = 0
    @page_control.addTarget(self, action: "change_page", forControlEvents: UIControlEventValueChanged)

    @pour_controller = PourController.new
    @pour_controller.view.frame = [[0, 0], [SCROLL_PAGE_WIDTH, SCROLL_PAGE_HEIGHT]]
    @scroll_view << @pour_controller.view

    @activity_controller = ActivityController.new #alloc.initWithStyle(UITableViewStyleGrouped, frame: [[0,0],[0,0]])
    @activity_controller.view.frame = [[SCROLL_PAGE_WIDTH, 0], [SCROLL_PAGE_WIDTH, SCROLL_PAGE_HEIGHT]]
    @scroll_view << @activity_controller.view

    @metrics_controller = ActivityController.new #alloc.initWithStyle(UITableViewStyleGrouped, frame: [[0,0],[0,0]])
    @metrics_controller.view.frame = [[SCROLL_PAGE_WIDTH * 2, 0], [SCROLL_PAGE_WIDTH, SCROLL_PAGE_HEIGHT]]
    @scroll_view << @metrics_controller.view

    self.view << @scroll_view
    self.view << @page_control

    @page_control_used = false

    @pour_update_observer = App.notification_center.observe "PourUpdateNotification" do |notification|
      pour_update(notification.userInfo.symbolize_keys) unless notification.userInfo.nil?
    end

    @pour_timeout_observer = App.notification_center.observe "PourTimeoutNotification" do |_|
      end_pour
    end
  end

  def viewDidUnload
    App.notification_center.unobserve @pour_update_observer
    App.notification_center.unobserve @pour_timeout_observer
    @pour_update_observer = nil
    @pour_timeout_observer = nil
  end

  def scrollViewDidScroll(scroll_view)
    return if @page_control_used

    page_width = @scroll_view.frame.size.width
    frational_page = ((@scroll_view.contentOffset.x - page_width / 2) / page_width).floor + 1
    page = frational_page.round
    @page_control.currentPage = page
  end

  def scrollViewWillBeginDragging(scroll_view)
    if @scroll_view.isScrollEnabled
      @page_control_used = false
    end
  end

  def scrollViewDidEndDecelerating(scroll_view)
    if @scroll_view.isScrollEnabled
      @page_control_used = false
    end
  end

  def change_page
    puts ""
    puts "ContextController > change_page"

    @page_control_used = true
    frame = [[@scroll_view.frame.size.width * @page_control.currentPage, 0], @scroll_view.frame.size]
    @scroll_view.scrollRectToVisible(frame, animated: true)
  end

  def pour_update(pour)
    if @page_control.currentPage != 0
      @scroll_view.scrollRectToVisible(@pour_controller.view.frame, animated: true) unless @page_control.currentPage == 0
      @last_frame = [[SCROLL_PAGE_WIDTH * @page_control.currentPage, 0], [SCROLL_PAGE_WIDTH, SCROLL_PAGE_HEIGHT]]
    end

    @pour_controller.update_pour(pour)
  end

  def end_pour
    @scroll_view.scrollRectToVisible(@last_frame, animated: true) if @last_frame
    @last_frame = nil

    @pour_controller.reset_pour
  end
end
