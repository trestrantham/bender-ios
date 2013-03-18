class ShadowBox < UIView
  def initWithFrame(frame)
    if super
      self.layer.masksToBounds = false
      self.layer.cornerRadius = 3.5
      self.layer.borderColor = "#111".uicolor.CGColor
      self.layer.borderWidth = 2
      self.layer.shadowColor = "#666".uicolor.CGColor
      self.layer.shadowOffset = [0, 1]
      self.layer.shadowOpacity = 1
      self.layer.shadowRadius = 0
      self.backgroundColor = "#333".uicolor

      shadow_box_image = "shadow_box".uiimage
      shadow_box_image = shadow_box_image.stretchableImageWithLeftCapWidth(22, topCapHeight: 22)
      shadow_box = UIImageView.alloc.initWithImage(shadow_box_image)
      shadow_box.contentMode = UIViewContentModeScaleToFill
      shadow_box.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      shadow_box.frame = self.bounds
      shadow_box.layer.cornerRadius = 5
      shadow_box.clipsToBounds = true
      self << shadow_box
    end

    self
  end
end
