class PourController < UIViewController
  def viewDidLoad
    super

    @current_mode = :normal

    self.view.backgroundColor = :clear.uicolor
    self.view = ShadowBox.alloc.initWithFrame(self.view.bounds)

    @beer_image_view = UIImageView.alloc.initWithImage("pour-beer-8".uiimage)
    @beer_image_view.frame = [[20, 20], [103, 154]]
    self.view << @beer_image_view

    @pour_volume_label = UILabel.alloc.initWithFrame [[150, 20], [262, 162]]
    @pour_volume_label.font = UIFont.boldSystemFontOfSize(72)
    @pour_volume_label.text = "0.0 oz"
    @pour_volume_label.textColor = "#2481c2".uicolor
    @pour_volume_label.shadowColor = "#111".uicolor
    @pour_volume_label.shadowOffset = [0, 1]
    @pour_volume_label.textAlignment = UITextAlignmentCenter
    @pour_volume_label.backgroundColor = :clear.uicolor
    self.view << @pour_volume_label

    # Setup our Add Drinker button
    button_image = "button".uiimage.resizableImageWithCapInsets(UIEdgeInsetsMake(22, 7, 23, 7))
    button_image_selected = "button-selected".uiimage.resizableImageWithCapInsets(UIEdgeInsetsMake(22, 7, 23, 7))

    @button = UIButton.custom
    @button.frame = [[445, 20], [262, 162]]
    @button.setBackgroundImage(button_image, forState: UIControlStateNormal)
    @button.setBackgroundImage(button_image_selected, forState: UIControlStateHighlighted)
    @button.setTitle("Done", forState: UIControlStateNormal)
    @button.titleLabel.font = :bold.uifont(36)
    @button.titleLabel.shadowColor = "#111".uicolor
    @button.titleLabel.shadowOffset = [0, -2]
 
    self.view << @button
  end

  def update_pour(pour = {})
    puts ''
    puts "PourController > update_pour"

    puts "volume = #{pour[:volume].to_f.round(1)}"
    @pour_volume_label.text = "#{pour[:volume].to_f.round(1)} oz"

    progress = pour[:volume].to_i > 8 ? 8 : pour[:volume].to_i
    @beer_image_view.image = "pour-beer-#{progress}".uiimage
  end
  
  def reset_pour
    puts ""
    puts "PourController > reset_pour"

    @pour_volume_label.text = "0.0 oz"
    @beer_image_view.image = "pour-beer-0".uiimage
  end

  def set_mode(mode = :normal)
    puts ""
    puts "PourController > set_mode: #{mode}"
    @current_mode = mode

    if @current_mode == :edit
      @button.off(:touch)
      @button.on(:touch) do
        App.notification_center.post "PourEditSavedNotification"
      end

      @button.setTitle("Save", forState: UIControlStateNormal)
    else
      @button.off(:touch)
      @button.on(:touch) do
        App.notification_center.post "PourTimeoutNotification"
      end

      @button.setTitle("Done", forState: UIControlStateNormal)
    end
  end
end
