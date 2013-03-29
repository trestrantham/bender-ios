class ContextPageControl < UIPageControl
  def init
    super

    @normal_image ||= "page_control_normal".uiimage
    @current_image ||= "page_control_current".uiimage

    self.currentPage = 0

    self
  end

  def setCurrentPage(page)
    super

    update_dots
  end

  def setNumberOfPages(pages)
    super

    update_dots
  end

  def updateCurrentPageDisplay
    super

    update_dots
  end

  def endTrackingWithTouch(touch, withEvent: event)
    super

    update_dots
  end

  def update_dots
    if @normal_image || @current_image
      dot_views = self.subviews

      (0..dot_views.count - 1).each do |i|
        dot = dot_views[i]
        dot.frame = [[dot.frame.origin.x, dot.frame.origin.y], [10, 10]]
        dot.image = i == self.currentPage ? @current_image : @normal_image
      end
    end
  end

#   def drawRect(control_rect)
#     control_rect = self.bounds
#     spacing = 10
#     rect = CGRect.new

#       UIRectFill(control_rect)

#     return if self.hidesForSinglePage && self.numberOfPages == 1

#     @normal_image ||= "page_control".uiimage
#     @selected_image ||= "page_control_selected".uiimage

#     rect.size.height = @normal_image.size.height
#     rect.size.width = @normal_image.size.width
#     rect.origin.x = ((control_rect.size.width - rect.size.width) / 2).floor
#     rect.origin.y = ((control_rect.size.height - rect.size.height) / 2).floor
#     rect.size.width = @normal_image.size.width

#     (0..self.numberOfPages - 1).each do |i|
#       image = i == self.currentPage ? @selected_image : @normal_image
#       image.drawInRect rect
#       rect.origin.x += @selected_image.size.width + spacing
#     end
#   end

#   def setCurrentPage(page)
#     super

#     self.setNeedsDisplay
#   end

#   def setNumberOfPages(pages)
#     super

#     self.setNeedsDisplay
#   end
end
