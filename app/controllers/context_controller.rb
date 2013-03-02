class ContextController < UIViewController
  SCROLL_PAGE_WIDTH = 788

  def viewDidLoad
    @scroll_view = UIScrollView.alloc.initWithFrame([[0, 0], [768, 251]])
    @scroll_view.pagingEnabled = true
    @scroll_view.contentSize = [768 * 2, 251]
    @scroll_view.showsHorizontalScrollIndicator = false
    @scroll_view.showsVerticalScrollIndicator = false
    @scroll_view.scrollsToTop = false
    @scroll_view.backgroundColor = UIColor.lightGrayColor
    self.view.addSubview(@scroll_view)

    @activity_controller = ActivityController.alloc.initWithStyle(UITableViewStyleGrouped, frame: [[0,0],[0,0]])
    @activity_controller.view.frame = [[0, 0], [768, 251]]
    @scroll_view.addSubview(@activity_controller.view)

    @metrics_controller = MetricsController.alloc.initWithStyle(UITableViewStyleGrouped, frame: [[0,0],[0,0]])
    @metrics_controller.view.frame = [[768, 0], [768, 251]]
    @scroll_view.addSubview(@metrics_controller.view)

    #headerSeperatorLine = ShadowView.alloc.initWithFrame([[-5, 0], [778, 20]], withHeight: 1, withShadowSize: 10, withShadowBlur: 10, withColor: UIColor.#darkGrayColor)
    #self.view.addSubview(headerSeperatorLine)
  end
end