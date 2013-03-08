class ContextController < UIViewController
  SCROLL_PAGE_WIDTH = 768

  def viewDidLoad
    @scroll_view = UIScrollView.alloc.initWithFrame([[0, 0], [728, 211]])
    @scroll_view.contentSize = [728 * 2, 211]
    @scroll_view.backgroundColor = "#333".uicolor
    @scroll_view.scrollsToTop = false
    @scroll_view.bounces = false
    @scroll_view.pagingEnabled = true
    @scroll_view.showsHorizontalScrollIndicator = false
    @scroll_view.showsVerticalScrollIndicator = false

    @scroll_view.layer.masksToBounds = true
    @scroll_view.layer.borderColor = :black.uicolor.CGColor
    @scroll_view.layer.borderWidth = 1

    @activity_controller = ActivityController.new #alloc.initWithStyle(UITableViewStyleGrouped, frame: [[0,0],[0,0]])
    @activity_controller.view.frame = [[0, 0], [728, 211]]
    @scroll_view << @activity_controller.view

    @metrics_controller = MetricsController.alloc.initWithStyle(UITableViewStyleGrouped, frame: [[0,0],[0,0]])
    @metrics_controller.view.frame = [[728, 0], [728, 211]]
    @scroll_view << @metrics_controller.view
    
    self.view << @scroll_view
  end
end
