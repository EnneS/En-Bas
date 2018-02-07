class Hero
  attr_reader :x, :y

  def initialize(x, y, map)
    @map = map

    @x = x
    @y = y
    @velocityY = 0

    @dir = :left
    @sprinting = false
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
          if @sprinting == false
            @x += 1
          else
            @x += 2
          end
        end }
    end

    if move_x < 0
      @dir = :left
      @image = @images[2]
      (-move_x).times {
        if peutSeDeplacer(-1, 0)
          if @sprinting == false
            @x -= 1
          else
            @x -= 2
          end
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

  def setSprinting(bool)
    @sprinting = bool
  end

end
