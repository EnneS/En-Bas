class Monstre
    attr_reader :x, :y, :type

    def initialize(type, x, y, map, hero)
      @map = map
      @type = type


      if @type == 0
        @pv = 200
        @degats = 15
      end
      if @type == 1
        @pv = 150
        @degats = 20
      end
      @cooldown = 700
      @noms = Array.new(3)
      @noms[0] = "loup"
      @noms[1] = "bat"
      @x = x
      @y = y

      @speed = 4

      if @type == 0
        @focusRangeIdle = 10
        @focusRangeActive = 15
      end
      if @type == 1
        @focusRangeIdle = 15
        @focusRangeActive = 20
      end
      @hero = hero

      @velocityY = 0

      @focus = nil

      @lastAttack = (Time.now.to_f*1000.0).to_i
      @lastMovement = (Time.now.to_f*1000.0).to_i
      @lastHit = (Time.now.to_f*1000.0).to_i

      @xt = 0
      @yt = 0
      @delay = 2500

      @direction = 1

      nom = @noms[type]

      @imagesDroite = []
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite1.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite2.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite3.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite4.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite5.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite6.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite7.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite8.png",{ :retro => true}))

      @imagesGauche = []
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche1.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche2.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche3.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche4.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche5.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche6.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche7.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche8.png",{ :retro => true}))

      if @type == 0
        @imagesFace = []
        @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face1.png",{ :retro => true}))
        @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face2.png",{ :retro => true}))
        @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face3.png",{ :retro => true}))
        @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face4.png",{ :retro => true}))
        @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face5.png",{ :retro => true}))
        @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face6.png",{ :retro => true}))
        @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face7.png",{ :retro => true}))
        @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face8.png",{ :retro => true}))
        @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face9.png",{ :retro => true}))
        @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face10.png",{ :retro => true}))
        @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face11.png",{ :retro => true}))
        @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face12.png",{ :retro => true}))

        @image = @imagesFace[0]
      end
      if @type == 1
        @image = @imagesDroite[0]
      end
    end

    def draw
      @image.draw(@x - 20, @y - @image.height*3, ZOrder::Hero, 3, 3) # on le draw à partir du bas du sprite (utile pour la collision)
    end

    def subirDegats(degats)
      @pv -= degats
      return @pv <= 0
    end

    def attack(hero)
      if @lastAttack < (Time.now.to_f*1000.0).to_i - @cooldown
        @lastAttack = (Time.now.to_f*1000.0).to_i
        return hero.subirDegats(@degats)
      end
    end

    def peutSeDeplacer(offs_x, offs_y)
      # Regarde dans les directions (offs_x et offs_y) si le prochain bloc est solide
      if @type == 0
        return !@map.solidLoup(@x + offs_x, @y + offs_y) && !@map.solidLoup(@x + offs_x, @y + offs_y - 45)
      end
      if @type == 1
        return !@map.solidBat(@x + offs_x, @y + offs_y) && !@map.solidBat(@x + offs_x, @y + offs_y - 45)
      end
    end

    def update(move_x)
      indicesRun = [0,1,2,3,4,5,6,7]
      indicesIdle = [0,1,2,3,4,5,6,7,8,9,10,11]

      # Actualisation de l'image en fonction de la direction
      if (move_x == 0)
        index = indicesIdle[Gosu::milliseconds / 150 % indicesIdle.size]
        @image = @imagesFace[index]
      end
      if (@velocityY < 0)
      #SAUT   @image = @jump
      end

      # Mouvement horizontal, se déplace si le prochain bloc dans la direction n'est pas solide
      if move_x > 0
        index = indicesRun[Gosu::milliseconds / 150 % indicesRun.size]
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
        index = indicesRun[Gosu::milliseconds / 150 % indicesRun.size]
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

    def updateAir(move_x, move_y)
      indices = [0,1,2,3,4,5,6,7]
      if move_y > 0
        move_y.times {
          if peutSeDeplacer(0, 1)
            @y += 1
          end
        }
      end

      if move_y < 0
        (-move_y).times {
          if peutSeDeplacer(0, -1)
            @y -= 1
          end
        }
      end

      if (move_x == 0)
        index = indices[Gosu::milliseconds / 40 % indices.size]
        @image = @imagesDroite[index]
      end

      if move_x > 0
        index = indices[Gosu::milliseconds / 40 % indices.size]
        @image = @imagesDroite[index]
        move_x.times {
          if peutSeDeplacer(1, 0)
            @x += 1
          end
        }
      end

      if move_x < 0
        index = indices[Gosu::milliseconds / 40 % indices.size]
        @image = @imagesGauche[index]
        (-move_x).times {
          if peutSeDeplacer(-1, 0)
            @x -= 1
          end
        }
      end

    end

    def jump
      if @map.solidLoup(@x, @y +1) # il saute seulement s'il n'est pas dans les airs
        @velocityY = -21
      end
    end

    def HeroInRange(distance)
      return ((@hero.x-@x).abs<= distance*64) && ((@hero.y-@y).abs<=distance*64)
    end
    def IA ()
      if @type == 0
        IA_Terre()
      end
      if @type == 1
        IA_Air()
      end
    end
    def IA_Terre
      n = (Time.now.to_f*1000.0).to_i
      if n - @lastMovement > @delay
        if @focus == nil
          @delay = $rng.Random(5000) + 800
          @xt = ($rng.Random(25) - 12)*$scale*32 + @x
          @yt = 0
          @lastMovement = n
          @speed = 3
        else
          @delay = $rng.Random(300) + 200
          @xt = ($rng.Random(5) - 2)*$scale*32 + @hero.x
          @yt = 0
          @lastMovement = n
          @speed = 6
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
    def IA_Air
      n = (Time.now.to_f*1000.0).to_i
      if n - @lastMovement > @delay
        if @focus == nil
          @delay = $rng.Random(3000) + 500
          @xt = ($rng.Random(25) - 12)*$scale*32 + @x
          @yt = ($rng.Random(11) - 5)*$scale*32 + @y
          @lastMovement = n
          @speed = 3
        else
          @delay = $rng.Random(1000) + 200

          dist = ((@x - @hero.x)**2 + (@y - @hero.y)**2)**0.5

          @xt = ($rng.Random(dist/2 + 5) - dist/4 - 2)*$scale*4 + @hero.x
          @yt = ($rng.Random(dist/2 + 5) - dist/4 - 2)*$scale*4 + @hero.y


          @lastMovement = n
          @speed = 7
        end
      else
        xf = @xt - @x
        if xf != 0
          xf /= xf.abs
        end
        yf = @yt - @y
        if yf != 0
          yf /= yf.abs
        end
        updateAir((xf*@speed).to_i, (yf*@speed).to_i)
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
