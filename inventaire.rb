class Inventaire

=begin
 0 : Air
 1 : Grass
 2 : Dirt
 3 : Stone 

=end

  def initialize(places)
    @places = places #nombre de places de l'inventaire
    @items = Array.new(@places) {Array.new(2)} #en premier l'id en second le nombre
    vider()

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

  def items
    i = 0
    puts "\ninv"
    while i < @places do
        puts @items[i][0].to_s + " : " + @items[i][1].to_s
      i += 1
    end
    puts "\n"
  end

  def draw
    i = 0
    while i < @places do
        if @items[i][0] != -1 #si l'emplacement contient un item
          @images[@items[i][0]].draw(100+(100*i), 50, 3)

          nb = Gosu::Image.from_text @items[i][1].to_s, 30
          nb.draw(135 + (100*i), 50, 3)
        end
        i += 1
    end

  end

end
