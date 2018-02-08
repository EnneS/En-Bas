class Monstre

  DIST_RECO_E = 20
  DIST_RECO_S = 30

  DIST_BLOCAGE_X = 3
  DIST_BLOCAGE_Y = 3

  NB_FRAME_DEBLOCAGE = 150
  DELAI_TEMPORISATION_ATTAQUE = 900

  DIST_ATTAQUE = 1
  DEGATS = 10
  PV = 100


  def initialize(hero, x, y, velocityX, velocityY, )

    @hero = hero

    #position monstre
    @x = x
    @y = y

    #vitesse du monstre
    @velocityX = velocityX
    @velocityY = velocityY

    #historique deplacement
    @histDepX = []
    @histDepY = []

    #initialisation delai
    @delaiDeblocage = 0
    @delaiAttaque = 0

    @dateDerniereAttaque = (Time.now.to_f*1000,0).to_i
    distRecoS = false

    #vie
    @pv = PV

    #degats
    @degat = DEGATS

    # création d'un tableau qui contiendra les différentes images du monstre
    @images = []
    # on ajoute les 4 images dans le tableau
    @images.push(Gosu::Image.new("res/monstre/face.png"))

    # de base, le monstre est de face
    @image = @images[0]

  end

  attr_accessor :velocity,:hero

  def draw
    @image.draw(@x, @y, ZOrder::Hero)
  end

  def go_left
    @velocityX -= velocity
    @image = @images[2]
  end

  def go_right
    @velocityX += velocity
    @image = @images[3]
  end

  def go_up
    @velocityY -= velocity
    @image = @images[1]
  end

  def move
    @x += @velocityX
    @y += @velocityY

    @velocityX *= 1
    @velocityY *= 1
  end

  def detectHero(distance)

    return ((@hero.x-@x).abs<= distance) && ((@hero.y-@y).abs<=distance)

  end

  def deplacement(map)

    if bloquer
      @delaiDeblocage = NB_FRAME_DEBLOCAGE
    end

    #déplacement horizontale
    if @delaiDeblocage > 0
      @fdelaiDeblocage--
      if @hero.x>@x
        go_left
      else
        go_right
    else
      if @hero.x<@x
        go_left
      else
        go_right
    end

    #déplacement verticale
    if map[@x-1][@y+1] != 0 || map[@x+1][@y+1] != 0
      go_up

  end

  def bloquer
    
    histDepX.push(@x)
    histDepY.push(@y)

    if histDepX.size == 300
      moyX, moyY = 0

      for coordX in histDepX
        moyX += coordX
      end
      moyX /= 300
      histDepX = []

      for coordY in histDepX
        moyY += coordY
      end
      moyY /= 300
      histDepY = []

      if ((moyX-@x).abs< DIST_BLOCAGE_X) && ((moyY-@y).abs<DIST_BLOCAGE_Y)
        return true
      end

    end
    return false

  end

  def attack

    if @dateDerniereAttaque < ((Time.now.to_f*1000,0).to_i-DELAI_TEMPORISATION_ATTAQUE)
      @dateDerniereAttaque = (Time.now.to_f*1000,0).to_i
      hero.subirDegats(DEGATS)
    end


  end

  def subirDegats(degatsHero)

    @pv -= degatsHero

  end

  def update(map)


    if detectHero(DIST_RECO_E) && !distRecoS

      if detectHero(DIST_RECO_S) 
        #distRecoS = true 
      end

      deplacement(map)

      if detectHero(DIST_ATTAQUE)
        attack
      end

#    elsif detectHero(DIST_RECO_S)
#
#     deplacement(map)
#
#      if !detectHero(DIST_RECO_S)
#        distRecoS = false
#      end
#
#      if detectHero(DIST_ATTAQUE)
#        attack
#      end
#
#    end

    if pv<0
      return false
    end

    return true

end
