class Inventaire

=begin
 0 : Air
 1 : Grass
 2 : Dirt
 3 : Stone

=end
attr_reader :selected, :items

  def initialize(places)
    @places = places #nombre de places de l'inventaire
    @items = Array.new(@places) {Array.new(2)} #en premier l'id en second le nombre
    vider()

    @barre = Gosu::Image.new("res/barre.png")
    @case = Gosu::Image.new("res/case.png")

    @images = []
    @images[0] = 0 #air
    @images.push(Gosu::Image.new("res/tiles/grass.png"))
    @images.push(Gosu::Image.new("res/tiles/dirt.png"))
    @images.push(Gosu::Image.new("res/tiles/stone.png"))

    @selected = 0
  end

  def vider
    i = 0
    while i < @places do
      @items[i][0] = -1
      @items[i][1] = -1
      i += 1
    end
  end

  def contains(id)
    i = 0
    while i < @places && @items[i][0] != id do
      i += 1
    end
    if i != @places
      return i
    else
      return -1
    end
  end

  def pick(id,nb)
    emplacement = contains(id)
    if emplacement != -1 and @items[emplacement][1] >= nb
      @items[emplacement][1] -= nb
      if @items[emplacement][1] == nb
        @items[emplacement][0] = -1
        @items[emplacement][1] = -1
      end
      return nb
    end
    return 0
  end

  def placeVide()
    i = 0
    while i < @places && @items[i][0] != -1 do
      i += 1
    end
    if i != @places
      return i
    else
      return -1
    end
  end

  def store(id,nb)
    emplacement = contains(id)
    vide = placeVide()
    if emplacement != -1
      @items[emplacement][1] += nb
      return true
    elsif placeVide() != -1
      @items[vide][0] = id
      @items[vide][1] = nb
      return true
    else
      return 0
    end
  end

  def idItem(n)
    return @items[n][0]
  end

  def nbItems(id)
    return @items[id][1]
  end

  def setSelected(n)
    @selected = n
  end

  def draw
    @barre.draw(1920-@barre.width, 0, 3)
    i = 0
    while i < @places do
      @case.draw((1920-@case.width-(@barre.width/6)), 1080/4/@places + ((1080/@places)*i), 4)

        if @items[i][0] != -1 #si l'emplacement contient un item
          @images[@items[i][0]].draw((1920-(@images[1].width)-(@case.width/2)-(@barre.width/6)), 1080/4/@places + ((1080/@places)*i) + 16, 6, 2, 2)

          $font.draw(@items[i][1].to_s, 1870,  1080/4/@places + ((1080/@places)*i) + 60, 7)
        end
        i += 1
    end

  end

end