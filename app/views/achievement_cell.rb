class AchievementCell < UITableViewCell
  attr_accessor :name, :desc, :user_name, :value

  CELL_WIDTH = 300
  CELL_HEIGHT = 44
  PADDING = 8

  def initWithStyle(style, reuseIdentifier: cell_identifier)
    super

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

    @name = UILabel.alloc.initWithFrame([[PADDING, 
                                                      5], 
                                                     [CELL_WIDTH / 2,
                                                      21]])
    @name.font = :bold.uifont(18)
    @name.textColor = "#a6cce6".uicolor
    @name.backgroundColor = :clear.uicolor
    @name.adjustsFontSizeToFitWidth = true
    @name.shadowColor = "#111".uicolor
    @name.shadowOffset = [0, -1]

    @desc = UILabel.alloc.initWithFrame([[PADDING, 
                                                      27], 
                                                     [CELL_WIDTH / 2, 
                                                      10]])
    @desc.font = :system.uifont(10)
    @desc.textColor = "#999".uicolor
    @desc.backgroundColor = :clear.uicolor
    @desc.adjustsFontSizeToFitWidth = true
    @desc.shadowColor = "#111".uicolor
    @desc.shadowOffset = [0, -1]

    @user_name = UILabel.alloc.initWithFrame([[CELL_WIDTH / 2 + PADDING, 
                                          5], 
                                         [CELL_WIDTH / 2 - PADDING * 2, 
                                          21]])
    @user_name.font = :bold.uifont(18)
    @user_name.textAlignment = UITextAlignmentRight
    @user_name.textColor = "#eee".uicolor
    @user_name.backgroundColor = :clear.uicolor
    @user_name.adjustsFontSizeToFitWidth = true
    @user_name.shadowColor = "#111".uicolor
    @user_name.shadowOffset = [0, -1]

    @value = UILabel.alloc.initWithFrame([[CELL_WIDTH / 2 + PADDING,
                                           27],
                                          [CELL_WIDTH / 2 - PADDING * 2, 
                                           10]])
    @value.font = :system.uifont(10)
    @value.textAlignment = UITextAlignmentRight
    @value.textColor = "#999".uicolor
    @value.backgroundColor = :clear.uicolor
    @value.adjustsFontSizeToFitWidth = true
    @value.shadowColor = "#111".uicolor
    @value.shadowOffset = [0, -1]

    self << @name
    self << @desc
    self << @user_name
    self << @value

    self
  end
end
