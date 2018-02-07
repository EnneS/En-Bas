class Window < Gosu::Window

  WIDTH, HEIGHT = 1920, 1080

  def initialize(width, height)
    super
    self.caption = "Hardcore Survival"

    @background_image = Gosu::Image.new("res/blue.jpg")

    @map = Map.new()
    @map.generate(1, 2000, 23, 7, 6, 32)
    #@map.load()
    @hero = Hero.new(100, 100, @map)
    @inventaire = Inventaire.new(10)
    @inventaire.store(1, 4)
    @inventaire.store(2, 7)


    @cursor = Gosu::Image.new("res/cursor.png")
    @camera_x = @camera_y = 0

  end

  def update
    # Actions du héro
    move_x = 0
    move_x -= 6 if Gosu.button_down? Gosu::KB_LEFT
    move_x += 6 if Gosu.button_down? Gosu::KB_RIGHT
    @hero.update(move_x)
    @hero.jump if Gosu::button_down?(Gosu::KbSpace)
    @hero.setSprinting(true) if Gosu::button_down?(Gosu::KbLeftShift)
    @hero.setSprinting(false) if !Gosu::button_down?(Gosu::KbLeftShift)

    @camera_x = [[@hero.x - WIDTH / 2, 0].max, (1280*30) * 50 - WIDTH].min
    @camera_y = [[@hero.y - HEIGHT / 2, 0].max, 150*30 * 50 - HEIGHT].min

    
    if button_down?(Gosu::MsLeft)

      if @hero.dernierBlocCasse < (Time.now.to_f*1000).to_i-500
        cursor_x = self.mouse_x
        cursor_y = self.mouse_y
        bloc_x, bloc_y = @map.trouveBloc(cursor_x,cursor_y,@camera_x,@camera_y,@hero.x, @hero.y)
        @inventaire.store(@map.data[bloc_x][bloc_y],1)
        @map.detruireBloc(bloc_x,bloc_y)
        @hero.dernierBlocCasse = (Time.now.to_f*1000).to_i
        
      end
    end


    close if Gosu::button_down?(Gosu::KbEscape)
  end

  def draw
     @background_image.draw 0, 0, -2
    @cursor.draw self.mouse_x, self.mouse_y, 99
    @inventaire.draw
    Gosu.translate(-@camera_x, -@camera_y) do
      @hero.draw
      @map.draw(@hero.x, @hero.y)
    end
  end

end