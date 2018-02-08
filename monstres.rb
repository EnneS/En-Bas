class Hero
    attr_reader :x, :y
  
    def initialize(x, y, nom, map)
      @map = map
  
      @x = x
      @y = y
      @velocityY = 0
      @image = @imagesFace[1]
  
      @direction = 1
  
      @imagesDroite = []
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite1.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite2.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite3.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite4.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite5.png",{ :retro => true}))
  
      @imagesGauche = []
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche1.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche2.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche3.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche4.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche5.png",{ :retro => true}))
  
      @imagesFace = []
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face1.png",{ :retro => true}))
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face2.png",{ :retro => true}))
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face3.png",{ :retro => true}))
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face4.png",{ :retro => true}))
    end
  
    def draw
      @image.draw(@x - 30, @y - @image.height*1.5, ZOrder::Hero, 1.5, 1.5) # on le draw à partir du bas du sprite (utile pour la collision)
    end
  
    def peutSeDeplacer(offs_x, offs_y)
      # Regarde dans les directions (offs_x et offs_y) si le prochain bloc est solide
      not @map.solid(@x + offs_x, @y + offs_y) and not @map.solid(@x + offs_x, @y + offs_y - 45)
    end
  
    def update(move_x)
      indices = [0] * 5 + [1] * 4 + [2] * 6 + [3] * 8
      index = indices[Gosu::milliseconds / 20 % indices.size]
  
      # Actualisation de l'image en fonction de la direction
      if (move_x == 0)
        @image = @imagesFace[index]
      end
      if (@velocityY < 0)
      #SAUT   @image = @jump
      end
  
      # Mouvement horizontal, se déplace si le prochain bloc dans la direction n'est pas solide
      if move_x > 0
        @direction = 1
        @image = @imagesDroite[index]
        move_x.times {
          if peutSeDeplacer(1, 0)
            @x += 1
          end }
      end
  
      if move_x < 0
        @direction = -1
        @image = @imagesGauche[index]
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
  