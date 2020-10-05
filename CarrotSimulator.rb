require 'gosu'

#Constants to change quickly
ORIGINAL_TIME_RAINING = 100
STARTING_SCALE = 0.2
X_OFFSET = 5

module ZOrder
  BACKGROUND, MIDDLE, TOP = *0..2
end

#Multiple clouds can exist at once
class Cloud
  attr_accessor :x, :y, :choice, :rain_ratio, :rain_choice, :rain_spawn_y, :rain_ratio

  def initialize(x, y, choice, rain_ratio)
    @x = x
    @y = y
    @choice = choice
    @rain_choice = 1
    @rain_ratio = rain_ratio
  end
end

#Multiple carrots are made
class Carrot
  attr_accessor :current_scale, :raining, :cloud, :x, :y, :time_spent_raining, :carrot_position, :sprouted

  def initialize(x, y, current_scale, raining)
    @x = x
    @y = y
    @current_scale = current_scale
    @raining = raining
    @time_spent_raining = ORIGINAL_TIME_RAINING
    @sprouted = false
  end
end

class GameWindow < Gosu::Window
  def initialize
    @width = 640
    @height = 480
    @ground_height = 2 * @height / 5
    @carrot_offset = 11
    @Array_of_Carrots = Array.new()
    @mouse_locs = [0,0]
    @raining = false
    @cloud_choice = 0
    @carrot_positions = [1, 0.6, 1.4, 0.25, 1.8]

    super(@width, @height, false)
    self.caption = "Carot Simulator"

    #Images
    @background_image = Gosu::Image.new("carrot_media/background.png")
    @carrot_root = Gosu::Image.new("carrot_media/carrot_root.png")
    @carrot_top = Gosu::Image.new("carrot_media/carrot_top.png")
    @cloud_1 = Gosu::Image.new("carrot_media/rain_cloud_1.png")
    @cloud_2 = Gosu::Image.new("carrot_media/rain_cloud_2.png")
    @cloud_3 = Gosu::Image.new("carrot_media/rain_cloud_3.png")
    @rain_1 = Gosu::Image.new("carrot_media/rain_1.png")
    @rain_2 = Gosu::Image.new("carrot_media/rain_2.png")
    @rain_3 = Gosu::Image.new("carrot_media/rain_3.png")

    #Complex variables
    @carrot_height = @carrot_root.height + @carrot_top.height
    @first_x = (@width / 2) - ((@carrot_root.width * STARTING_SCALE) / 2)
    @first_y = @ground_height

    #Create first carrot, then put into the array of carrots
    @first_carrot = Carrot.new(@first_x, @first_y, STARTING_SCALE, false)
    @first_carrot.carrot_position = 1
    @Array_of_Carrots << @first_carrot

  end

  def update
    i = 0
    while i < @Array_of_Carrots.length
      if(@Array_of_Carrots[i].cloud != nil)
        if((@Array_of_Carrots[i].raining == true) && (@Array_of_Carrots[i].time_spent_raining > 0))
          @Array_of_Carrots[i].time_spent_raining -= 1
          if(@Array_of_Carrots[i].time_spent_raining % 3 == 0)
            @Array_of_Carrots[i].cloud.rain_choice += 1
            if(@Array_of_Carrots[i].cloud.rain_choice > 3)
              @Array_of_Carrots[i].cloud.rain_choice = 1
            end
          end
        elsif(@Array_of_Carrots[i].time_spent_raining == 0)
          grow_carrot(@Array_of_Carrots[i])
        end
      end
      i += 1
    end
  end

  def needs_cursor?
    true
  end

  def button_down(id)
    case id
    when Gosu::MsLeft
      @mouse_locs = [mouse_x, mouse_y]
      carrot_clicked = clicked_carrot(mouse_x, mouse_y)
      if(carrot_clicked)
        if(@Array_of_Carrots[carrot_clicked].cloud == nil)

          #Spawns first cloud for the carrot clicked
          cloud_spawn_y = (@height / 5) + rand(-20..20)
          cloud_spawn_x = @Array_of_Carrots[carrot_clicked].x + rand(-10..10)
          cloud_choice = rand(1..3)
          rain_ratio = (@Array_of_Carrots[carrot_clicked].y - @cloud_1.height - cloud_spawn_y) / @rain_1.height.to_f
          new_cloud = Cloud.new(cloud_spawn_x, cloud_spawn_y, cloud_choice, rain_ratio)
          @Array_of_Carrots[carrot_clicked].cloud = new_cloud
          @Array_of_Carrots[carrot_clicked].raining = true
          @Array_of_Carrots[carrot_clicked].cloud.rain_spawn_y = @Array_of_Carrots[carrot_clicked].cloud.y + @cloud_1.height
        else

          #Respawns cloud
          @Array_of_Carrots[carrot_clicked].cloud.y = (@height / 5) + rand(-20..20)
          @Array_of_Carrots[carrot_clicked].cloud.x = @Array_of_Carrots[carrot_clicked].x + rand(-10..10)
          @Array_of_Carrots[carrot_clicked].cloud.choice = rand(1..3)
          @Array_of_Carrots[carrot_clicked].cloud.rain_ratio = (@Array_of_Carrots[carrot_clicked].y  - @cloud_1.height - @Array_of_Carrots[carrot_clicked].cloud.y) / @rain_1.height.to_f
          @Array_of_Carrots[carrot_clicked].raining = true
          @Array_of_Carrots[carrot_clicked].cloud.rain_spawn_y = @Array_of_Carrots[carrot_clicked].cloud.y + @cloud_1.height
        end
      end
    end
  end

  #Increases the size of the carrot passed through
  def grow_carrot(carrot)
    carrot.raining = false
    carrot.time_spent_raining = ORIGINAL_TIME_RAINING
    if(carrot.sprouted == false)
      carrot.current_scale *= 1.1
      carrot.x = ((@width / 2) - ((@carrot_root.width * carrot.current_scale) / 2)) * carrot.carrot_position
      carrot.y = @ground_height
      puts("Current scale is: " + carrot.current_scale.to_s)
      if(carrot.current_scale >= 0.3 && carrot.sprouted != true)
        if(@Array_of_Carrots.length < 5)
          new_x =  @carrot_positions[@Array_of_Carrots.length] * @first_x
          new_carrot = Carrot.new(new_x, @first_y, STARTING_SCALE, false) #scan1
          new_carrot.carrot_position = @carrot_positions[@Array_of_Carrots.length]
          @Array_of_Carrots << new_carrot
        end
        carrot.sprouted = true
      end
    end
  end

  #Was a carrot clicked? Which carrot was clicked? Let's find out!
  def clicked_carrot(mouse_x, mouse_y)
    i = 0
    while i < @Array_of_Carrots.length
      if(((mouse_x > @Array_of_Carrots[i].x) and (mouse_x < (@Array_of_Carrots[i].x + @carrot_root.width * @Array_of_Carrots[i].current_scale))) and ((mouse_y > (@Array_of_Carrots[i].y - @carrot_top.height)) and (mouse_y < (@Array_of_Carrots[i].y + @carrot_height * @Array_of_Carrots[i].current_scale))))
        return i
      end
      i += 1
    end
    return nil
  end

  def draw
    #temporary_background()
    @background_image.draw(0, 0, z = ZOrder::BACKGROUND, scale_x = 0.5, scale_y = 0.5)
    i = 0
    while i < @Array_of_Carrots.length
      @carrot_root.draw(@Array_of_Carrots[i].x, @Array_of_Carrots[i].y, z = ZOrder::MIDDLE, scale_x = @Array_of_Carrots[i].current_scale, scale_y = @Array_of_Carrots[i].current_scale)
      @carrot_top.draw(@Array_of_Carrots[i].x, @Array_of_Carrots[i].y - @carrot_top.height * @Array_of_Carrots[i].current_scale, z = ZOrder::MIDDLE, scale_x = @Array_of_Carrots[i].current_scale, scale_y = @Array_of_Carrots[i].current_scale)
      if(@Array_of_Carrots[i].raining)
        case @Array_of_Carrots[i].cloud.choice
        when 1
          @cloud_1.draw(@Array_of_Carrots[i].cloud.x, @Array_of_Carrots[i].cloud.y, 2)
        when 2
          @cloud_2.draw(@Array_of_Carrots[i].cloud.x, @Array_of_Carrots[i].cloud.y, 2)
        when 3
          @cloud_3.draw(@Array_of_Carrots[i].cloud.x, @Array_of_Carrots[i].cloud.y, 2)
        end

        case @Array_of_Carrots[i].cloud.rain_choice
        when 1
          @rain_1.draw(@Array_of_Carrots[i].cloud.x, @Array_of_Carrots[i].cloud.rain_spawn_y, 1, 1, @Array_of_Carrots[i].cloud.rain_ratio)
        when 2
          @rain_2.draw(@Array_of_Carrots[i].cloud.x, @Array_of_Carrots[i].cloud.rain_spawn_y, 1, 1, @Array_of_Carrots[i].cloud.rain_ratio)
        when 3
          @rain_3.draw(@Array_of_Carrots[i].cloud.x, @Array_of_Carrots[i].cloud.rain_spawn_y, 1, 1, @Array_of_Carrots[i].cloud.rain_ratio)
        end
      end
      i += 1
    end
  end

  #Left over function. Only existed as a temporary background
  def temporary_background()
    draw_quad(0, 0, 0xff_61fff7, @width, 0, 0xff_61fff7, 0, @ground_height, 0xff_61fff7, @width, @ground_height, 0xff_61fff7, ZOrder::BACKGROUND)
    draw_quad(0, @ground_height, 0xff_693f26, @width, @ground_height, 0xff_693f26, 0, @height, 0xff_693f26, @width, @height, 0xff_693f26, ZOrder::BACKGROUND)
  end
end

window = GameWindow.new
window.show
