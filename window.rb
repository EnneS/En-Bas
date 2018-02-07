class Window < Gosu::Window

  WIDTH, HEIGHT = 1920, 1080

  def initialize(width, height)
    super
    self.caption = "Hardcore Survival"

    $font = Gosu::Font.new(self, "res/pokemon_pixel_font.ttf", 40)
    $fontXL = Gosu::Font.new(self, "res/pokemon_pixel_font.ttf", 70)
    @gamebackground_image = Gosu::Image.new("res/blue.jpg")

    @map = Map.new()
    @map.generate(3, 3000, 128, 8, 7, 60)
    #@map.load()
    @hero = Hero.new((((@map.data.size-1)/2)*60)-1, (@map.ground((@map.data.size-1)/2)*60)-1, @map)
    @inventaire = Inventaire.new(6)
    @inventaire.store(4, 1)

    @cursor = Gosu::Image.new("res/cursor.png")
    @camera_x = @camera_y = 0

    @gameStarted = true
  end

  def update
    close if Gosu::button_down?(Gosu::KbEscape)
    @inventaire.setSelected(0) if Gosu::button_down?(Gosu::Kb1)
    @inventaire.setSelected(1) if Gosu::button_down?(Gosu::Kb2)
    @inventaire.setSelected(2) if Gosu::button_down?(Gosu::Kb3)
    @inventaire.setSelected(3) if Gosu::button_down?(Gosu::Kb4)
    @inventaire.setSelected(4) if Gosu::button_down?(Gosu::Kb5)
    @inventaire.setSelected(5) if Gosu::button_down?(Gosu::Kb6)

    if @gameStarted == false
      # Evénements du menu
      #
      #
      #

    else
      # Actions du héro
      move_x = 0
      move_x -= 6 if Gosu.button_down? Gosu::KB_LEFT
      move_x += 6 if Gosu.button_down? Gosu::KB_RIGHT
      move_x *= 2 if Gosu::button_down?(Gosu::KbLeftShift)
      @hero.update(move_x)
      @hero.jump if Gosu::button_down?(Gosu::KbSpace)

      # Viewport ! Il s'agit d'un tableau avec les coordonnées max possible de la fenêtre (en l'occurence la taille de la map)
      # Si on arrive aux extrêmités il faut arrêter le scroll (on utilise ainsi min et max par rapport à la taille de la fenêtre)
      @camera_x = [[@hero.x - WIDTH / 2, 0].max, (@map.data.size)*60 - WIDTH].min
      @camera_y = [[@hero.y - HEIGHT / 2, 0].max, (@map.data[0].size)*60 - HEIGHT].min

    end


    if button_down?(Gosu::MsLeft)

      cursor_x = self.mouse_x
      cursor_y = self.mouse_y

      v = @inventaire.idItem(@inventaire.selected)

      if (v != 4) && (v != 5)

        x,y = @map.trouveBlocP(cursor_x,cursor_y,@camera_x,@camera_y,@hero.x, @hero.y)

        if @hero.dernierBlocPoser < (Time.now.to_f*1000).to_i-500 and x != -1 and y != -1

          bloc_x, bloc_y = @map.trouveBlocP(cursor_x,cursor_y,@camera_x,@camera_y,@hero.x, @hero.y)
          #puts bloc_x.to_s+" . "+bloc_y.to_s
          @map.poserBloc(bloc_x,bloc_y,v)
          @inventaire.pick(v,1)
          @hero.dernierBlocPoser = (Time.now.to_f*1000).to_i

        end

      end

      if v == 4

        x,y = @map.trouveBloc(cursor_x,cursor_y,@camera_x,@camera_y,@hero.x, @hero.y)

        if @hero.dernierBlocCasse < (Time.now.to_f*1000).to_i-500 and x != -1 and y != -1
          bloc_x, bloc_y = @map.trouveBloc(cursor_x,cursor_y,@camera_x,@camera_y,@hero.x, @hero.y)
          id = @map.data[bloc_x][bloc_y]
          
          @map.detruireBloc(bloc_x,bloc_y)
          if @map.data[bloc_x][bloc_y] == 0
            @inventaire.store(id,1)
          end
          @hero.dernierBlocCasse = (Time.now.to_f*1000).to_i

        end
      end
    end
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
