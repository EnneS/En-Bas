class Window < Gosu::Window

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