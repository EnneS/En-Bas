class Window < Gosu::Window

  WIDTH, HEIGHT = 1920, 1080

  def initialize(width, height)
    super
    self.caption = "Hardcore Survival"

    $font = Gosu::Font.new(self, "res/pokemon_pixel_font.ttf", 40)
    $fontXL = Gosu::Font.new(self, "res/pokemon_pixel_font.ttf", 70)
    @gamebackground_image = Gosu::Image.new("res/blue.jpg")

    @map = Map.new()
    #@map.generate(3, 3000, 128, 8, 7, 60)
    @map.load()
    @hero = Hero.new(((@map.data.size-1)*60)/2, 250, @map)
    @inventaire = Inventaire.new(6)
    @inventaire.store(1, 4)
    @inventaire.store(2, 7)


    @cursor = Gosu::Image.new("res/cursor.png")
    @camera_x = @camera_y = 0

    @gameStarted = true
  end

  def update

    if @gameStarted == false

    else
      # Actions du héro
      move_x = 0
      move_x -= 6 if Gosu.button_down? Gosu::KB_LEFT
      move_x += 6 if Gosu.button_down? Gosu::KB_RIGHT
      move_x *= 2 if Gosu::button_down?(Gosu::KbLeftShift)
      @hero.update(move_x)
      @hero.jump if Gosu::button_down?(Gosu::KbSpace)

      @camera_x = [[@hero.x - WIDTH / 2, 0].max, (1280*30) * 50 - WIDTH].min
      @camera_y = [[@hero.y - HEIGHT / 2, 0].max, 150*30 * 50 - HEIGHT].min

    end


    if button_down?(Gosu::MsLeft)

      if @hero.dernierBlocCasse < (Time.now.to_f*1000).to_i-500
        cursor_x = self.mouse_x
        cursor_y = self.mouse_y

        bloc_x, bloc_y = @map.trouveBloc(cursor_x,cursor_y,@camera_x,@camera_y,@hero.x, @hero.y)

        v = @map.data[bloc_x][bloc_y]

        @map.detruireBloc(bloc_x,bloc_y)
        if @map.data[bloc_x][bloc_y] == 0
          @inventaire.store(v,1)
        end
        @hero.dernierBlocCasse = (Time.now.to_f*1000).to_i

      end
    end


    close if Gosu::button_down?(Gosu::KbEscape)
  end

  def draw
    @cursor.draw self.mouse_x, self.mouse_y, 99
    if @gameStarted == false
      # Le jeu n'a pas commencé :
      # Affichage du menu
      $fontXL.draw("Jouer !", (WIDTH/2)-30, HEIGHT/2, 0)

    else
      # Le jeu a commencé : on affiche le background, la profondeur, l'inventaire
      # le héro et la map
      @gamebackground_image.draw 0, 0, -2

      #Profondeur du joueur
      $fontXL.draw("Profondeur : " + (@hero.y/60).to_s, 20, 20, 5)

      @inventaire.draw
      Gosu.translate(-@camera_x, -@camera_y) do
        @hero.draw
        @map.draw(@hero.x, @hero.y)
      end
    end
  end

end
