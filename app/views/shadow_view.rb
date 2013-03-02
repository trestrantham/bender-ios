class ShadowView < UIView
  SHADOW_BOX_OFFSET = 20

  def initWithFrame(frame, withHeight: height, withShadowSize: sSize, withShadowBlur: sBlur, withColor: aColor)
    super.initWithFrame(frame)

    @lineSize = height
    @shadowSize = -sSize
    @shadowBlur = sBlur
    @color = aColor
    self.backgroundColor = UIColor.clearColor
    
    self
  end

  def drawRect(rect)
    currentContext = UIGraphicsGetCurrentContext()
    @color.set
    rgbColorspace = CGColorSpaceCreateDeviceRGB()
    shadowColor = CGColorCreate(rgbColorspace, [0.0, 0.0, 0.0, 0.75].to_pointer(:float))
    CGContextSetShadowWithColor(currentContext, CGSizeMake(0, -@shadowSize), @shadowBlur, shadowColor)
    CGContextFillRect(currentContext, CGRectMake(-5, @lineSize - SHADOW_BOX_OFFSET, rect.size.width + 10, SHADOW_BOX_OFFSET))
    
    CGColorRelease(shadowColor)
    CGColorSpaceRelease(rgbColorspace)
  end
end