class Hero

    def initialize(x, y)
      @x = x
      @y = y
      @velocityX = 0.0
      @velocityY = 0.0
  
      # création d'un tableau qui contiendra les différentes images du héros
      @images = []
      # on ajoute les 4 images dans le tableau
      @images.push(Gosu::Image.new("res/hero/face.png"))
      @images.push(Gosu::Image.new("res/hero/dos.png"))
      @images.push(Gosu::Image.new("res/hero/gauche.png"))
      @images.push(Gosu::Image.new("res/hero/droite.png"))
      # de base, le héros est de face
      @image = @images[0]
    end
  
    def draw
      @image.draw(@x, @y, ZOrder::Hero)
    end
  
    def go_left
      @velocityX -= 0.6
      # changement de l'image du héros : tourné vers la gauche
      @image = @images[2]
    end
  
    def go_right
      @velocityX += 0.6
      # changement de l'image du héros : tourné vers la droite
      @image = @images[3]
    end
  
    def jump
      if !dansLesAir # il saute seulement s'il n'est pas dans les airs
        @velocityY = -9.8*2
      end
    end
  
    def sprint
      @velocityX *= 1.05
    end
  
    def move
      @x += @velocityX
      @y += @velocityY
  
      if @x >= (1920 + @image.width)
        @x = 0 - @image.width
      elsif @x <= (0 - @image.width)
        @x = 1920 + @image.width
      end
  
      @velocityX *= 0.90 # inertie
    end
  
    def gravity
      if dansLesAir
        @velocityY += 0.98
      else
        @velocityY = 0
      end
    end
  
    def dansLesAir
      if @y < 1080-@image.height
        return true
      end
    end
  
    def getY
      return @y
    end
  
    def setY(val)
      @y = val
    end
  
  end