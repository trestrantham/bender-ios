class ContextController < UIViewController
  SCROLL_PAGE_WIDTH = 728
  SCROLL_PAGE_HEIGHT = 191

  def viewDidLoad
    @scroll_view = UIScrollView.alloc.initWithFrame([[0, 0], [SCROLL_PAGE_WIDTH, SCROLL_PAGE_HEIGHT]])
    @scroll_view.delegate = self
    @scroll_view.contentSize = [SCROLL_PAGE_WIDTH * 2, SCROLL_PAGE_HEIGHT]
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
    @page_control.numberOfPages = 2 
    @page_control.currentPage = 0
    @page_control.addTarget(self, action: "change_page", forControlEvents: UIControlEventValueChanged)

    @activity_controller = ActivityController.new #alloc.initWithStyle(UITableViewStyleGrouped, frame: [[0,0],[0,0]])
    @activity_controller.view.frame = [[0, 0], [SCROLL_PAGE_WIDTH, SCROLL_PAGE_HEIGHT]]
    @scroll_view << @activity_controller.view

    @metrics_controller = MetricsController.alloc.initWithStyle(UITableViewStyleGrouped, frame: [[0,0],[0,0]])
    @metrics_controller.view.frame = [[SCROLL_PAGE_WIDTH, 0], [SCROLL_PAGE_WIDTH, SCROLL_PAGE_HEIGHT]]
    @scroll_view << @metrics_controller.view
    
    self.view << @scroll_view
    self.view << @page_control

    @page_control_used = false
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
end
