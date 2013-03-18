class AchievementCell < UITableViewCell
  attr_accessor :achievement_name, :achievement_desc, :name, :value

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

    @achievement_name = UILabel.alloc.initWithFrame([[PADDING, 
                                                      5], 
                                                     [CELL_WIDTH / 2,
                                                      21]])
    @achievement_name.font = :bold.uifont(18)
    @achievement_name.textColor = "#a6cce6".uicolor
    @achievement_name.backgroundColor = :clear.uicolor
    @achievement_name.adjustsFontSizeToFitWidth = true
    @achievement_name.shadowColor = "#111".uicolor
    @achievement_name.shadowOffset = [0, -1]

    @achievement_desc = UILabel.alloc.initWithFrame([[PADDING, 
                                                      27], 
                                                     [CELL_WIDTH / 2, 
                                                      10]])
    @achievement_desc.font = :system.uifont(10)
    @achievement_desc.textColor = "#999".uicolor
    @achievement_desc.backgroundColor = :clear.uicolor
    @achievement_desc.adjustsFontSizeToFitWidth = true
    @achievement_desc.shadowColor = "#111".uicolor
    @achievement_desc.shadowOffset = [0, -1]

    @name = UILabel.alloc.initWithFrame([[CELL_WIDTH / 2 + PADDING, 
                                          5], 
                                         [CELL_WIDTH / 2 - PADDING * 2, 
                                          21]])
    @name.font = :bold.uifont(18)
    @name.textAlignment = UITextAlignmentRight
    @name.textColor = "#eee".uicolor
    @name.backgroundColor = :clear.uicolor
    @name.adjustsFontSizeToFitWidth = true
    @name.shadowColor = "#111".uicolor
    @name.shadowOffset = [0, -1]

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

    self << @achievement_name
    self << @achievement_desc
    self << @name
    self << @value

    self
  end
end
