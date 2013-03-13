class BeerCell < UITableViewCell
  LABELS = [:beer_name, :beer_brewery, :beer_style, :beer_abv, :keg_tapped_on, :keg_empty_on, :keg_volume_consumed, 
            :keg_volume_remaining, :keg_volume_consumed_label, :keg_volume_remaining_label]
  LABELS.each { |label| attr_accessor label }

  CELL_WIDTH = 388
  CELL_HEIGHT = 216 # 200 + PADDING
  PADDING = 8
  IMAGE_WIDTH = 100

  TEXT_COLOR = "#333".uicolor
  TEXT_COLOR_LIGHT = "#666".uicolor
  TEXT_COLOR_DARK = "#111".uicolor
  TEXT_SELECTED_COLOR = "#eee".uicolor
  TEXT_SELECTED_COLOR_LIGHT = "#a6cce6".uicolor

  @beer_style_text = ""
  @beer_abv_text = ""
  @keg_tapped_on_text = ""
  @keg_empty_on_text = ""

  def initWithStyle(style, reuseIdentifier: cell_identifier)
    super

    self.selectionStyle = UITableViewCellSelectionStyleNone

    # Create a container to hold all cell views and to set a background color
    @container = UIView.alloc.initWithFrame([[0, 0], [CELL_WIDTH, CELL_HEIGHT]])
    @container.backgroundColor = "#ddd".uicolor

    beer_image = "bender_beer.jpg".uiimage
    @beer_image = UIImageView.alloc.initWithImage(beer_image.rounded)
    @beer_image.frame = [[PADDING, PADDING], [IMAGE_WIDTH, IMAGE_WIDTH]]

    LABELS.each do |label|
      tmp = UILabel.new
      tmp.font = :system.uifont(14)
      tmp.textColor = TEXT_COLOR
      tmp.shadowColor = "#eee".uicolor
      tmp.shadowOffset = [0, 1]
      tmp.adjustsFontSizeToFitWidth = true
      tmp.numberOfLines = 0
      # tmp.lineBreakMode = NSLineBreakByWordWrapping
      tmp.backgroundColor = :clear.uicolor
      instance_variable_set("@#{label}", tmp)
    end

    @beer_name.textColor = TEXT_COLOR_DARK

    [@beer_name, @beer_brewery].each { |label| label.font = :bold.uifont(18) }
    [@keg_volume_remaining, @keg_volume_consumed].each { |label| label.font = :bold.uifont(26) }
    [@keg_volume_remaining, @keg_volume_consumed, @keg_volume_remaining_label, @keg_volume_consumed_label].each { |label| label.textAlignment = NSTextAlignmentCenter }
    @keg_volume_remaining_label.text = "oz Remaining"
    @keg_volume_consumed_label.text = "oz Consumed"

    [@keg_volume_remaining_label, @keg_volume_consumed_label].each do |label|
      label.font = :system.uifont(12)
      label.textColor = TEXT_COLOR_LIGHT
    end

    # Set frames
    label_inset = IMAGE_WIDTH + PADDING * 2
    label_width = CELL_WIDTH - IMAGE_WIDTH - PADDING * 3

    @beer_name.frame = [[label_inset, PADDING], [label_width, 50]]
    @beer_brewery.frame = [[label_inset, 50 + PADDING], [label_width, 50]]
    @beer_style.frame = [[label_inset, 100 + PADDING], [label_width, 25]]
    @beer_abv.frame = [[label_inset, 125 + PADDING], [label_width, 25]]
    @keg_tapped_on.frame = [[label_inset, 150 + PADDING], [label_width, 25]]
    @keg_empty_on.frame = [[label_inset, 175 + PADDING], [label_width, 25]]
    @keg_volume_remaining.frame = [[PADDING, IMAGE_WIDTH + PADDING * 2], [IMAGE_WIDTH, 50 - PADDING * 3]]
    @keg_volume_remaining_label.frame = [[PADDING, IMAGE_WIDTH + 50 - PADDING], [IMAGE_WIDTH, PADDING * 2]]
    @keg_volume_consumed.frame = [[PADDING, IMAGE_WIDTH +  PADDING * 2 + 50], [IMAGE_WIDTH, 50 - PADDING * 3]]
    @keg_volume_consumed_label.frame = [[PADDING, IMAGE_WIDTH + 100 - PADDING], [IMAGE_WIDTH, PADDING * 2]]

    @container << @beer_image
    @container << @beer_name
    @container << @beer_brewery
    @container << @beer_style
    @container << @beer_abv
    @container << @keg_tapped_on
    @container << @keg_empty_on
    @container << @keg_volume_remaining
    @container << @keg_volume_consumed
    @container << @keg_volume_remaining_label
    @container << @keg_volume_consumed_label

    self << @container

    self
  end

  def setSelected(selected, animated: animated)
    if selected
      @container.backgroundColor = "#2481c2".uicolor
    
      LABELS.each do |label|
        instance_variable_get("@#{label}").shadowColor = "#333".uicolor
        instance_variable_get("@#{label}").shadowOffset = [0, -1]
        instance_variable_get("@#{label}").textColor = "#eee".uicolor
      end

      @beer_style.attributedText = "Style: ".attrd.color(TEXT_SELECTED_COLOR_LIGHT).italic + "#{@beer_style_text}".bold

      @beer_abv.attributedText = "ABV: ".attrd.color(TEXT_SELECTED_COLOR_LIGHT).italic + "#{@beer_abv_text}%".bold
      @keg_tapped_on.attributedText = "Tapped On: ".attrd.color(TEXT_SELECTED_COLOR_LIGHT).italic + "#{@keg_tapped_on_text}".bold
      @keg_empty_on.attributedText = "Estimated Finish: ".attrd.color(TEXT_SELECTED_COLOR_LIGHT).italic + "#{@keg_empty_on_text}".bold
      @keg_volume_remaining_label.textColor = TEXT_SELECTED_COLOR_LIGHT
      @keg_volume_consumed_label.textColor = TEXT_SELECTED_COLOR_LIGHT
    else
      @container.backgroundColor = "#ddd".uicolor

      LABELS.each do |label|
        instance_variable_get("@#{label}").shadowColor = "#eee".uicolor
        instance_variable_get("@#{label}").shadowOffset = [0, 1]
        instance_variable_get("@#{label}").textColor = "#111".uicolor
      end

    @beer_style.attributedText = "Style: ".attrd.color(TEXT_COLOR_LIGHT).italic + "#{@beer_style_text}".bold
      @beer_abv.attributedText = "ABV: ".attrd.color(TEXT_COLOR_LIGHT).italic + "#{@beer_abv_text}%".bold
      @keg_tapped_on.attributedText = "Tapped On: ".attrd.color(TEXT_COLOR_LIGHT).italic + "#{@keg_tapped_on_text}".bold
      @keg_empty_on.attributedText = "Estimated Finish: ".attrd.color(TEXT_COLOR_LIGHT).italic + "#{@keg_empty_on_text}".bold
      @keg_volume_remaining_label.textColor = TEXT_COLOR_LIGHT
      @keg_volume_consumed_label.textColor = TEXT_COLOR_LIGHT
    end
  end

  def set_beer_style(text)
    @beer_style_text = text

    @beer_style.attributedText = "Style: ".attrd.color(TEXT_COLOR_LIGHT) + "#{@beer_style_text}".bold
  end

  def set_beer_abv(text)
    @beer_abv_text = text

    @beer_abv.attributedText = "ABV: ".attrd.color(TEXT_COLOR_LIGHT) + "#{@beer_abv_text}%".bold
  end

  def set_keg_tapped_on(text)
    @keg_tapped_on_text = text

    @keg_tapped_on.attributedText = "Tapped On: ".attrd.color(TEXT_COLOR_LIGHT) + "#{@keg_tapped_on_text}".bold
  end

  def set_keg_empty_on(text)
    @keg_empty_on_text = text

    @keg_empty_on.attributedText = "Estimated Finish: ".attrd.color(TEXT_COLOR_LIGHT) + "#{@keg_empty_on_text}".bold
  end

  def show_shadow(direction = :bottom)
    case direction
    when :top 
      @container.layer.shadowOffset = [0, 0]
    when :bottom 
      @container.layer.shadowOffset = [0, 0]
    end
    @container.layer.shadowColor = "#111".uicolor.CGColor
    @container.layer.shadowOpacity = 1
    @container.layer.shadowRadius = 8 
    @container.clipsToBounds = false
    @container.layer.masksToBounds = false
  end
end
