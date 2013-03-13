class BButton < UIButton
  BORDER_RADIUS = 5
  HEIGHT = 44
  WIDTH = 1 + BORDER_RADIUS * 2 # 1 point stretchable area

  def self.buttonWithType(type)
    super buttonWithType(UIButtonTypeCustom)
  end

  def init
    if super
      setup
    end

    self
  end

  def setup
    @background_image ||= draw_button(false).resizableImageWithCapInsets(UIEdgeInsetsMake(BORDER_RADIUS, BORDER_RADIUS, BORDER_RADIUS, BORDER_RADIUS), 
                                                                         resizingMode: UIImageResizingModeStretch)

    @background_image_highlighted ||= draw_button(true).resizableImageWithCapInsets(UIEdgeInsetsMake(BORDER_RADIUS, BORDER_RADIUS, BORDER_RADIUS, BORDER_RADIUS), 
                                                                                    resizingMode: UIImageResizingModeStretch)

    setBackgroundImage(@background_image, forState: UIControlStateNormal)
    setBackgroundImage(@background_image_highlighted, forState: UIControlStateHighlighted)
  end

  def draw_button(highlighted)
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(WIDTH, HEIGHT), false, 0)
    context = UIGraphicsGetCurrentContext()
    color_space = CGColorSpaceCreateDeviceRGB()

    border_color = "#777".uicolor # :black.uicolor
    shadow_color = :black.uicolor(0.5)
    top_color = "#666".uicolor
    bottom_color = "#555".uicolor
    highlight_color = :black.uicolor # "#777".uicolor

    gradient_colors = [top_color.CGColor, bottom_color.CGColor]
    gradient = CGGradientCreateWithColors(color_space, gradient_colors, nil)

    highlight_gradient_colors = [bottom_color.CGColor, top_color.CGColor]
    highlight_gradient = CGGradientCreateWithColors(color_space, highlight_gradient_colors, nil)

    rounded_rect_path = UIBezierPath.bezierPathWithRoundedRect([[0, 0], [WIDTH, HEIGHT]], cornerRadius: BORDER_RADIUS)
    # rounded_rect_path = UIBezierPath.bezierPathWithRoundedRect([[0, 0], [WIDTH, HEIGHT]], byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight, cornerRadii: [BORDER_RADIUS, BORDER_RADIUS])
    rounded_rect_path.addClip

    background = @highlighted ? highlight_gradient : gradient
    CGContextDrawLinearGradient(context, background, [140, 0], [140, HEIGHT - 1], 0)

    border_color.setStroke
    rounded_rect_path.lineWidth = 5
    rounded_rect_path.stroke

    # inner_shadow_path = UIBezierPath.bezierPathWithRoundedRect([[0, 1.5], [WIDTH, HEIGHT]], cornerRadius: BORDER_RADIUS * 4 / BORDER_RADIUS)
    # # inner_shadow_path = UIBezierPath.bezierPathWithRoundedRect([[0, 1.5], [WIDTH, HEIGHT]], byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight, cornerRadii: [BORDER_RADIUS, BORDER_RADIUS])
    # shadow_color.setStroke
    # inner_shadow_path.lineWidth = 2
    # inner_shadow_path.stroke

    inner_glow_path = UIBezierPath.bezierPathWithRoundedRect([[1.5, 1.5], [WIDTH - 3, HEIGHT - 3]], cornerRadius: BORDER_RADIUS)
    # inner_glow_path = UIBezierPath.bezierPathWithRoundedRect([[1.5, 1.5], [WIDTH - 3, HEIGHT - 3]], cornerRadius: BORDER_RADIUS * 4 / 5)
    # inner_glow_path = UIBezierPath.bezierPathWithRoundedRect([[1.5, 1.5], [WIDTH - 3, HEIGHT - 3]], byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight, cornerRadii: [BORDER_RADIUS, BORDER_RADIUS])
    highlight_color.setStroke
    inner_glow_path.lineWidth = 2
    inner_glow_path.stroke

    background_image = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()
    # CGGradientRelease(gradient)
    # CGGradientRelease(highlight_gradient)
    # CGColorSpaceRelease(color_space)
    puts "end of draw_button"
    background_image
  end
end
