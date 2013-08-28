class StyleController < NSObject
  def self.apply_style
    # Grab our navbar appearance
    nav_bar_appearance = UINavigationBar.appearance

    # Setup our navbar background images
    nav_bar_image = "navbar".uiimage
    nav_bar_image = nav_bar_image.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 20, 0, 20))
    nav_bar_appearance.setBackgroundImage(nav_bar_image, forBarMetrics: UIBarMetricsDefault)

    # Setup our navbar text attributes
    # Must use old hash syntax to keep from converting constants to symbols
    text_attributes = { UITextAttributeTextColor => "#111".uicolor,
                        UITextAttributeTextShadowColor => "#eee".uicolor,
                        UITextAttributeTextShadowOffset => NSValue.valueWithUIOffset(UIOffsetMake(0, 1))
                        # UITextAttributeFont => :bold.uifont(20)
    }

    nav_bar_appearance.setTitleTextAttributes(text_attributes)
  end
end

class UINavigationBar
  def willMoveToWindow(window)
    super

    apply_style
  end

  def apply_style
    self.layer.shadowColor = :black.uicolor.CGColor
    self.layer.shadowOffset = [0, 3]
    self.layer.shadowOpacity = 0.5
    self.layer.shouldRasterize = true
    self.clipsToBounds = false
  end
end
