class UserCell < UITableViewCell
  attr_accessor :user_name

  CELL_WIDTH = 300
  CELL_HEIGHT = 115

  def initWithStyle(style, reuseIdentifier: cell_identifier)
    super

    self.textColor = "#eee".uicolor

    # Create a container to hold all our cell views and to set a background color
    container = UIView.alloc.initWithFrame([[0, 0], [CELL_WIDTH, CELL_HEIGHT]])
    container.backgroundColor = "#555".uicolor
 
    highlight_top = UIView.alloc.initWithFrame([[0, 0], [CELL_WIDTH, 1]])
    highlight_top.backgroundColor = "#666".uicolor

    shadow_bottom = UIView.alloc.initWithFrame([[0, CELL_HEIGHT - 1],[CELL_WIDTH, 1]])
    shadow_bottom.backgroundColor = :black.uicolor

    user_image = "user".uiimage
    user_image_view = UIImageView.alloc.initWithImage(user_image.rounded)
    user_image_view.frame = [[20, 20], [75, 75]]

    @user_name = UILabel.alloc.initWithFrame([[115, 20], [CELL_WIDTH - 40, 20]])
    @user_name.font = :bold.uifont(24)
    @user_name.textColor = "#eee".uicolor
    @user_name.backgroundColor = :clear.uicolor
    @user_name.adjustsFontSizeToFitWidth = true

    container << highlight_top
    container << shadow_bottom
    container << user_image_view
    container << @user_name

    self << container

    self
  end
end
