class UserCell < UITableViewCell
  attr_accessor :user_name, :last_drink, :user_image_view

  CELL_WIDTH = 300
  CELL_HEIGHT = 66
  IMAGE_SIZE = 50
  PADDING = 8

  TEXT_COLOR_LIGHT = "#a6cce6".uicolor
  BACKGROUND_COLOR = "#2481c2".uicolor
  SELECTED_TEXT_COLOR_LIGHT = "#a6cce6".uicolor
  SELECTED_BACKGROUND_COLOR = "#2481c2".uicolor
  EDIT_TEXT_COLOR_LIGHT = "#E6C6AD".uicolor
  EDIT_BACKGROUND_COLOR = "#C28625".uicolor

  def initWithStyle(style, reuseIdentifier: cell_identifier)
    super

    @selected_background_color = SELECTED_BACKGROUND_COLOR

    self.selectionStyle = UITableViewCellSelectionStyleNone
    self.textColor = "#eee".uicolor

    # Create a container to hold all our cell views and to set a background color
    @container = UIView.alloc.initWithFrame([[0, 0], [CELL_WIDTH, CELL_HEIGHT]])
    self.backgroundView = @container
 
    # Top highlight line
    top_line_view = UIView.alloc.initWithFrame([[0, 0], [CELL_WIDTH, 1]])
    top_line_view.backgroundColor = "#494949".uicolor
    self << top_line_view

    # Bottom highlight line
    bottom_line_view = UIView.alloc.initWithFrame([[0, CELL_HEIGHT - 1], [CELL_WIDTH, 1]])
    bottom_line_view.backgroundColor = "#111".uicolor
    self << bottom_line_view

    user_image = "user#{rand(4) + 1}.jpg".uiimage
    @user_image_view = UIImageView.alloc.initWithImage(user_image)
    @user_image_view.frame = [[PADDING, PADDING], [IMAGE_SIZE, IMAGE_SIZE]]
    @user_image_view.layer.masksToBounds = true
    @user_image_view.layer.cornerRadius = 3.5
    @user_image_view.layer.borderColor = "#111".uicolor.CGColor
    @user_image_view.layer.borderWidth = 1
    @user_image_view.layer.shadowColor = "#eee".uicolor.CGColor
    @user_image_view.layer.shadowOffset = [0, 1]
    @user_image_view.layer.shadowOpacity = 1
    @user_image_view.layer.shadowRadius = 0

    @user_name = UILabel.alloc.initWithFrame([[IMAGE_SIZE + PADDING * 2,
                                               PADDING * 2],
                                              [CELL_WIDTH - IMAGE_SIZE + PADDING * 3,
                                               20]])
    @user_name.font = :bold.uifont(18)
    @user_name.textColor = "#eee".uicolor
    @user_name.backgroundColor = :clear.uicolor
    @user_name.adjustsFontSizeToFitWidth = true
    @user_name.shadowColor = "#111".uicolor
    @user_name.shadowOffset = [0, -1]

    @last_drink = UILabel.alloc.initWithFrame([[IMAGE_SIZE + PADDING * 2,
                                                CELL_HEIGHT - PADDING * 2 - 18],
                                               [CELL_WIDTH - IMAGE_SIZE + PADDING * 3,
                                                20]])
    @last_drink.font = :system.uifont(12)
    @last_drink.textColor = "#999".uicolor
    @last_drink.backgroundColor = :clear.uicolor
    @last_drink.adjustsFontSizeToFitWidth = true
    @last_drink.shadowColor = "#111".uicolor
    @last_drink.shadowOffset = [0, -1]

    self << @user_image_view
    self << @user_name
    self << @last_drink

    self
  end

  def setSelected(selected, animated: animated)
    puts ""
    puts "UserCell > setSelected"

    @selected = selected

    if selected
      @container.backgroundColor = @selected_background_color

      [:user_name, :last_drink].each do |label|
        instance_variable_get("@#{label}").shadowColor = "#333".uicolor
      end

      @last_drink.textColor = @selected_text_color_light
    else
      @container.backgroundColor = "#333".uicolor

      [:user_name, :last_drink].each do |label|
        instance_variable_get("@#{label}").shadowColor = "#111".uicolor
      end

      @last_drink.textColor = "#999".uicolor
    end
  end

  def set_user_email(user_email)
    puts ""
    puts "UserCell > set_user_email: #{user_email}"

    cleansed_email = user_email.gsub(/\s+/,"").downcase if user_email
    if cleansed_email
      digest = RmDigest::MD5.hexdigest(cleansed_email)
      gravatar = UIImage.imageWithData(NSData.dataWithContentsOfURL("http://www.gravatar.com/avatar/#{digest}?s=#{IMAGE_SIZE}".nsurl))
      @user_image_view.image = gravatar if gravatar
    else
      @user_image_view.image = "user#{rand(4) + 1}.jpg".uiimage
    end
  end

  def show_shadow(direction = :bottom)
    case direction
    when :top 
      self.layer.shadowOffset = [0, -1]
    when :bottom 
      self.layer.shadowOffset = [0, 0]
    end
    self.layer.shadowColor = "#111".uicolor.CGColor
    self.layer.shadowOpacity = 1
    self.layer.shadowRadius = 1 
    self.clipsToBounds = false
  end

  def set_mode(mode = :normal)
    puts ""
    puts "UserCell > set_mode: mode = #{mode}"

    if mode == :edit
      @selected_background_color = EDIT_BACKGROUND_COLOR
      @selected_text_color_light = EDIT_TEXT_COLOR_LIGHT
    else
      @selected_background_color = SELECTED_BACKGROUND_COLOR
      @selected_text_color_light = SELECTED_TEXT_COLOR_LIGHT
    end

    if @selected
      @container.backgroundColor = @selected_background_color
      @last_drink.textColor = @selected_text_color_light
    end
  end
end
