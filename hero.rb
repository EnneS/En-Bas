class Hero
<<<<<<< HEAD

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
=======
  attr_reader :x, :y

  def initialize(x, y, map)
    @map = map

    @x = x
    @y = y
    @velocityY = 0

    @dir = :left

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
    @image.draw(@x, @y - @image.height, 0, ZOrder::Hero) # on le draw à partir du bas du sprite (utile pour la collision)
  end

  def peutSeDeplacer(offs_x, offs_y)
    # Check at the center/top and center/bottom for map collisions
    not @map.solid(@x + offs_x, @y + offs_y) and not @map.solid(@x + offs_x, @y + offs_y - 45)
  end

  def update(move_x)
    # Select image depending on action
    if (move_x == 0)
      @image = @images[0]
    end
    if (@velocityY < 0)
    #SAUT   @image = @jump
    end

    # Directional walking, horizontal movement
    if move_x > 0
      @dir = :right
      @image = @images[3]
      move_x.times {
        if peutSeDeplacer(1, 0)
          @x += 1
        end }
    end

    if move_x < 0
      @dir = :left
      @image = @images[2]
      (-move_x).times {
        if peutSeDeplacer(-1, 0)
          @x -= 1
        end }
    end

    # Acceleration/gravity
    # By adding 1 each frame, and (ideally) adding vy to y, the player's
    # jumping curve will be the parabole we want it to be.
    @velocityY += 1

    # Vertical movement
    if @velocityY > 0
      @velocityY.times { if peutSeDeplacer(0, 1) then @y += 1 else @velocityY = 0 end }
    end
    if @velocityY < 0
      (-@velocityY).times { if peutSeDeplacer(0, -1) then @y -= 1 else @velocityY = 0 end }
    end
  end

  def jump
    if @map.solid(@x, @y +1) # il saute seulement s'il n'est pas dans les airs
      @velocityY = -19
    end
  end

  def sprint
    @velocityX *= 1.05
  end

end
>>>>>>> 4007a36b43a36d3e493856ed73727222e470eab2
