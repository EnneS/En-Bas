class Monstre
    attr_reader :x, :y, :type
  
    def initialize(type, x, y, map, hero)
      @map = map
      @type = type

      @noms = Array.new(3)
      @noms[0] = "loup"

      @x = x
      @y = y

      @speed = 4

      @focusRangeIdle = 10
      @focusRangeActive = 15

      @hero = hero

      @velocityY = 0

      @focus = nil

      @dateDerniereAttaque = (Time.now.to_f*1000.0).to_i
      @lastMovement = (Time.now.to_f*1000.0).to_i
      
      @xt = 0
      @yt = 0
      @delay = 2500

      @direction = 1
      
      nom = @noms[type]
      @imagesDroite = []
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/face.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/face.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/face.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/face.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/face.png",{ :retro => true}))
  
      @imagesGauche = []
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/face.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/face.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/face.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/face.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/face.png",{ :retro => true}))
  
      @imagesFace = []
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face.png",{ :retro => true}))
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face.png",{ :retro => true}))
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face.png",{ :retro => true}))
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face.png",{ :retro => true}))

      @image = @imagesFace[0]
    end
  
    def draw
      @image.draw(@x - 30, @y - @image.height*1.5, ZOrder::Hero, 1.5, 1.5) # on le draw à partir du bas du sprite (utile pour la collision)
    end
  
    def peutSeDeplacer(offs_x, offs_y)
      # Regarde dans les directions (offs_x et offs_y) si le prochain bloc est solide
      not @map.solid(@x + offs_x, @y + offs_y) and not @map.solid(@x + offs_x, @y + offs_y - 45)
    end
  
    def update(move_x)
      indices = [0] * 1 + [1] * 1 + [2] * 1 + [3] * 1
  
      # Actualisation de l'image en fonction de la direction
      if (move_x == 0)
        index = indices[Gosu::milliseconds / 300 % indices.size]
        @image = @imagesFace[index]
      end
      if (@velocityY < 0)
      #SAUT   @image = @jump
      end
  
      # Mouvement horizontal, se déplace si le prochain bloc dans la direction n'est pas solide
      if move_x > 0
        index = indices[Gosu::milliseconds / 100 % indices.size]
        @direction = 1
        @image = @imagesDroite[index]
        move_x.times {
          if peutSeDeplacer(1, 0)
            @x += 1
          else
            jump()
          end
        }
      end
  
      if move_x < 0
        index = indices[Gosu::milliseconds / 100 % indices.size]
        @direction = -1
        @image = @imagesGauche[index]
        (-move_x).times {
          if peutSeDeplacer(-1, 0)
            @x -= 1
          else
            jump()
          end
        }
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

    def HeroInRange(distance)
      return ((@hero.x-@x).abs<= distance*64) && ((@hero.y-@y).abs<=distance*64)
    end

    def IA_Terre
      n = (Time.now.to_f*1000.0).to_i
      if n - @lastMovement > @delay
        if @focus == nil
          @delay = $rng.Random(3000) + 500
          @xt = ($rng.Random(5) - 2)*$scale*32 + @x
          @yt = 0
          @lastMovement = n
          @speed = 3
        else
          @delay = $rng.Random(300) + 200
          @xt = ($rng.Random(5) - 2)*$scale*32 + @hero.x
          @yt = 0
          @lastMovement = n
          @speed = 8
        end
      else
        xf = @xt - @x
        if xf != 0
          xf /= xf.abs
        end
        
        update((xf*@speed).to_i)
      end
      if @focus == nil && HeroInRange(@focusRangeIdle)
        @focus = @hero
        @delay = 200
      end
      if @focus != nil && HeroInRange(@focusRangeActive)
        @focus = @hero
        @delay = 200
      end
    end
  
end
  