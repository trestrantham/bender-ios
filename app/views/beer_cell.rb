class BeerCell < UITableViewCell
  LABELS = [:beer_name, :beer_brewery, :beer_style, :keg_volume_consumed, :keg_volume_remaining]
  LABELS.each { |label| attr_accessor label }

  CELL_WIDTH = 428
  CELL_HEIGHT = 250

  def initWithStyle(style, reuseIdentifier: cell_identifier)
    super

    # Create a container to hold all cell views and to set a background color
    container = UIView.alloc.initWithFrame([[0, 0], [CELL_WIDTH, CELL_HEIGHT]])
    container.backgroundColor = "#ddd".uicolor

    highlight_top = UIView.alloc.initWithFrame([[0, 0], [CELL_WIDTH, 1]])
    highlight_top.backgroundColor = "#666".uicolor

    shadow_bottom = UIView.alloc.initWithFrame([[0, CELL_HEIGHT - 1],[CELL_WIDTH, 1]])
    shadow_bottom.backgroundColor = :black.uicolor

    beer_image = "bender_beer.jpg".uiimage
    @beer_image = UIImageView.alloc.initWithImage(beer_image.rounded)
    @beer_image.frame = [[20, 20], [100, 100]]

    @beer_name = UILabel.alloc.initWithFrame([[140, 20], [228, 40]])
    @beer_name.font = :bold.uifont(24)
    @beer_name.backgroundColor = :orange.uicolor
    @beer_name.adjustsFontSizeToFitWidth = true

    @beer_brewery = UILabel.alloc.initWithFrame([[140, 60], [228, 30]])
    @beer_brewery.font = :bold.uifont(18)
    @beer_brewery.backgroundColor = :blue.uicolor
    @beer_brewery.adjustsFontSizeToFitWidth = true

    @beer_style = UILabel.alloc.initWithFrame([[140, 90], [228, 30]])
    @beer_style.font = :normal.uifont(18)
    @beer_style.backgroundColor = :teal.uicolor
    @beer_style.adjustsFontSizeToFitWidth = true

    @keg_volume_remaining = UILabel.alloc.initWithFrame([[20, 140], [164, 50]])
    @keg_volume_remaining.backgroundColor = :purple.uicolor
    @keg_volume_remaining.adjustsFontSizeToFitWidth = true

    @keg_volume_consumed = UILabel.alloc.initWithFrame([[204, 140], [164, 50]])
    @keg_volume_consumed.backgroundColor = :green.uicolor
    @keg_volume_consumed.adjustsFontSizeToFitWidth = true

    container << highlight_top
    container << shadow_bottom
    container << @beer_image
    container << @beer_name
    container << @beer_brewery
    container << @beer_style
    container << @keg_volume_remaining
    container << @keg_volume_consumed

    self << container

    self
  end
end
