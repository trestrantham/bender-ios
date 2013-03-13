class PourController < UIViewController
  def viewDidLoad
    super

    self.title = "Pour"
    self.view.backgroundColor = :clear.uicolor

    @beer_image_view = UIImageView.alloc.initWithImage("beer_complete1".uiimage)
    @beer_image_view.frame = [[8, 8], [106, 176]]
    self.view << @beer_image_view

    @pour_volume_label = UILabel.alloc.initWithFrame [[0, 0], [728, 191]]
    @pour_volume_label.font = UIFont.boldSystemFontOfSize(72)
    @pour_volume_label.text = "0.0 oz"
    @pour_volume_label.textAlignment = UITextAlignmentCenter
    @pour_volume_label.backgroundColor = :clear.uicolor
    self.view << @pour_volume_label

    @pour_status_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @pour_status_button.setTitle("Done", forState:UIControlStateNormal)
    @pour_status_button.setTitle("Pour Complete!", forState:UIControlStateDisabled)
    @pour_status_button.sizeToFit
    @pour_status_button.center = CGPointMake(self.view.frame.size.width / 2, @pour_volume_label.center.y + 75)
    self.view << @pour_status_button

    @pour_status_button.enabled = true
    @pour_status_button.when(UIControlEventTouchUpInside) do
      App.notification_center.post "PourTimeoutNotification"
    end
  end

  def update_pour(pour = {})
    puts ''
    puts "PourController > update_pour"

    @pour_status_button.enabled = true

    puts "volume = #{pour[:volume].to_f.round(1)}"
    @pour_volume_label.text = "#{pour[:volume].to_f.round(1)} oz"

    progress = pour[:volume].to_f.round > 15 ? 15 : pour[:volume].to_f.round 
    @beer_image_view.image = "beer_complete#{progress}".uiimage
  end
  
  def reset_pour
    puts ""
    puts "PourController > reset_pour"

    @pour_volume_label.text = "0.0 oz"
    @beer_image_view.image = "beer_complete1".uiimage
  end
end
