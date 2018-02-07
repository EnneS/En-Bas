class Hero
  attr_reader :x, :y
  attr_accessor :dernierBlocCasse

  def initialize(x, y, map)
    @map = map

    @dernierBlocCasse = (Time.now.to_f*1000).to_i

    @x = x
    @y = y
    @velocityY = 0

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
    # Regarde dans les directions (offs_x et offs_y) si le prochain bloc est solide
    not @map.solid(@x + offs_x, @y + offs_y) and not @map.solid(@x + offs_x, @y + offs_y - 45)
  end

  def update(move_x)
    # Actualisation de l'image en fonction de la direction
    if (move_x == 0)
      @image = @images[0]
    end
    if (@velocityY < 0)
    #SAUT   @image = @jump
    end

    # Mouvement horizontal, se déplace si le prochain bloc dans la direction n'est pas solide
    if move_x > 0
      @image = @images[3]
      move_x.times {
        if peutSeDeplacer(1, 0)
          @x += 1
        end }
    end

    if move_x < 0
      @image = @images[2]
      (-move_x).times {
        if peutSeDeplacer(-1, 0)
          @x -= 1
        end }
    end

    # Gravité
    @velocityY += 1

    # Mouvement vertical, la vélocité augmente si le prochain bloc dans la direction n'est pas solide
    if @velocityY > 0
      @velocityY.times { if peutSeDeplacer(0, 1) then @y += 1 else @velocityY = 0 end }
    end
    if @velocityY < 0
      (-@velocityY).times { if peutSeDeplacer(0, -1) then @y -= 1 else @velocityY = 0 end }
    end
  end

  def jump
    if @map.solid(@x, @y +1) # il saute seulement s'il n'est pas dans les airs
      @velocityY = -21
    end
  end

end
