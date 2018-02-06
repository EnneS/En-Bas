class Window < Gosu::Window

<<<<<<< HEAD
    def initialize(width, height)
      super

      self.caption = "Hardcore Survival"
      @map = Map.new()
      @map.generate(10, 150, 10, 7, 6, 32)
      #@hero = Hero.new(width/2, height/2)
      #@song = Gosu::Song.new("res/music.mp3")
      #@song.volume = 0.25
      #@song.play(true)
    end
  
    def update
      # Actions du héro
      #@hero.go_left if Gosu::button_down?(Gosu::KbLeft)
      #@hero.go_right if Gosu::button_down?(Gosu::KbRight)
      #@hero.jump if Gosu::button_down?(Gosu::KbSpace)
      #@hero.sprint if Gosu::button_down?(Gosu::KbLeftShift)
      # Actualisation déplacement du héro
      #@hero.move
      # gravité sur le héro
      #@hero.gravity
  
      # On force la pos du héro au sol
      #if @hero.getY > 1080
      #  puts @hero.getY
      #  @hero.setY(1080)
      #end
  
      close if Gosu::button_down?(Gosu::KbEscape)
    end
  
    def draw
      #@hero.draw
      @map.draw
    end
  
  end
=======
  WIDTH, HEIGHT = 1920, 1080

  def initialize(width, height)
    super
    self.caption = "Hardcore Survival"
    @map = Map.new()
    @map.generate(10, 150, 23, 7, 6, 32)

    @hero = Hero.new(100, 100, @map)
    @song = Gosu::Song.new("res/music.mp3")
    @song.volume = 0.25
    @song.play(true)

    @background_image = Gosu::Image.new("res/blue.jpg")

    @camera_x = @camera_y = 0

  end

  def update
    # Actions du héro
    move_x = 0
    move_x -= 10 if Gosu.button_down? Gosu::KB_LEFT
    move_x += 10 if Gosu.button_down? Gosu::KB_RIGHT
    @hero.update(move_x)
    @hero.jump if Gosu::button_down?(Gosu::KbSpace)
    @hero.sprint if Gosu::button_down?(Gosu::KbLeftShift)

    @camera_x = [[@hero.x - WIDTH / 2, 0].max, (1280*30) * 50 - WIDTH].min
    @camera_y = [[@hero.y - HEIGHT / 2, 0].max, 150*30 * 50 - HEIGHT].min

    close if Gosu::button_down?(Gosu::KbEscape)
  end

  def draw
    @background_image.draw 0, 0, -2

    Gosu.translate(-@camera_x, -@camera_y) do
      @hero.draw
      @map.draw(@hero.x, @hero.y)
    end
  end
end
>>>>>>> 4007a36b43a36d3e493856ed73727222e470eab2
