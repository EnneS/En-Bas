$scale = 1.5 # scale des blocs (32pixels * $scale)
module Tiles
  Air = 0
  Grass = 1
  Earth = 2
  Stone = 3
  DarkStone = 4
  Water = 5
  Lava = 6
  Chest = 7
  Torch1 = 80
  Torch2 = 81
  Torch3 = 82
  Torch3 = 83

end
def min(a, b)
  return a < b ? a : b
end
def max(a, b)
  return a > b ? a : b
end
class RNG
  attr :seed, :m, :a, :c

  def initialize(seed)
    @seed = seed
    @m = 2**32
    @a = 1664525
    @c = 1013904223
  end
  def Random(max)
    @seed = (@a * @seed + @c) % @m;
    return @seed % max
  end
  def GenerateKeyPoint(amp)
    @seed = (@a * @seed + @c) % @m;
    return (@seed % amp) - (amp / 2)
  end
end
class Layer
  attr_accessor :octaves, :base_lvl, :material, :oct_nbr, :amplitude, :wave_length_pow
  def initialize(material, base_lvl, oct_nbr, amplitude, wave_length_pow)
    if oct_nbr > wave_length_pow
      puts "warning : oct_nbr > wave_length_pow"
    end
    @base_lvl, @material, @oct_nbr, @amplitude, @wave_length_pow = base_lvl, material, oct_nbr, amplitude, wave_length_pow
  end

  def generateNew(width_points)
    wl = 2 ** wave_length_pow
    tmp_wp = width_points

    @octaves = Array.new(oct_nbr){Array.new(tmp_wp)}
    for y in 0..oct_nbr - 1
      for x in 0..tmp_wp - 1
        octaves[y][x] = $rng.GenerateKeyPoint(amplitude / (1.7 ** y))

      end
      tmp_wp *= 2
    end
  end
  def generateOctaves(template, copy_n)
    if copy_n > @oct_nbr
      puts "copy_n too big"
      copy_n = oct_nbr
    end
    @octaves = Array.new(template.size)
    if copy_n > 0
      for i in 0..copy_n-1
        @octaves[i] = template[i]
      end
    end
    if oct_nbr > copy_n
      for j in copy_n..oct_nbr-1
        @octaves[j] = Array.new(template[j].size)
        for i in 0..template[j].size - 1
          @octaves[j][i] = $rng.GenerateKeyPoint(amplitude / (1.7**j))
        end
      end
    end
  end

end


class Map

  attr_reader :w, :h, :data, :lightmap, :images, :transparency, :shadow

  def initialize()
    @images = Array.new(90)
    @images[0] = 0 # air
    @images[1] = Gosu::Image.new("res/tiles/grass.png", {:tileable => true })
    @images[2] = Gosu::Image.new("res/tiles/dirt.png", {:tileable => true })
    @images[3] = Gosu::Image.new("res/tiles/stone.png", {:tileable => true })
    @images[7] = Gosu::Image.new("res/tiles/chest.png", {:tileable => true })

    (0..3).each do |i|
      @images[(8.to_s+i.to_s).to_i] = Gosu::Image.new("res/tiles/torch_000"+i.to_s+".png", {:tileable => true })
      @images[(9.to_s+i.to_s).to_i] = Gosu::Image.new("res/tiles/torch_right000"+i.to_s+".png", {:tileable => true })
      @images[(10.to_s+i.to_s).to_i] = Gosu::Image.new("res/tiles/torch_left000"+i.to_s+".png", {:tileable => true })
    end

    @transparency = Array.new(90)
    @transparency[0] = 1
    @transparency[1] = 7
    @transparency[2] = 7
    @transparency[3] = 9
    @transparency[7] = -5

    (0..3).each do |i|
      @transparency[(8.to_s+i.to_s).to_i] = 1
      @transparency[(9.to_s+i.to_s).to_i] = 1
      @transparency[(10.to_s+i.to_s).to_i] = 1
    end


    @light = Array.new(90)
    @light[0] = 0
    @light[1] = 0
    @light[2] = 0
    @light[3] = 0
    @light[7] = 15

    (0..3).each do |i|
      @light[(8.to_s+i.to_s).to_i] = 20
      @light[(9.to_s+i.to_s).to_i] = 20
      @light[(10.to_s+i.to_s).to_i] = 20
    end

    @shadow = Gosu::Image.new("res/tiles/shadow.png", {:tileable => true })
  end

  def save()
    File.open("terrain.map", "w+") do |file|
      Marshal.dump(@data, file)
    end
    File.open("lumieres.ltm", "w+") do |file|
      Marshal.dump(@lightmap, file)
    end
  end
  def load()
    File.open("terrain.map") do |file|
      @data = Marshal.load(file)
    end
    @w = @data.size
    @h = @data[0].size
    File.open("lumieres.ltm") do |file|
      @lightmap = Marshal.load(file)
    end
  end
  def setBlock(x, y, v)
    @data[x][y] = v
    updateLight(x, y, 0)
    #addBlockToWaitList(x-1, y)
    #addBlockToWaitList(x+1, y)
    #addBlockToWaitList(x, y-1)
    #addBlockToWaitList(x, y+1)
  end

  def interpolate(a, b, x)
    ft = x * Math::PI
    f = (1 - Math.cos(ft)) * 0.5;
    return a * (1 - f) + b * f;
  end

  def lightValue(x, y)
    if y < 0 then return 32 end
    if y >= @h then return -1 end
    if x < 0 then return -1 end
    if x >= @w then return -1 end
    return @lightmap[x][y]
  end

  def updateLight(x, y, stack_lvl)
    v = lightValue(x, y)
    if v < 0 || v == 32
      return
    end
    @lightmap[x][y] = 0
    vu = lightValue(x, y-1)
    if vu >= 32 - @transparency[0]
      @lightmap[x][y] = min(32 - @transparency[0], 32 - @transparency[@data[x][y]] + @light[@data[x][y]])
    else
      vb = lightValue(x, y+1)
      vl = lightValue(x-1, y)
      vr = lightValue(x+1, y)
=begin
      if @data[x][y] == Tiles::Air
        if y > 0 && @data[x][y-1] != Tiles::Air
          vu = 0
        end
        if y < @h-1 && @data[x][y+1] != Tiles::Air
           vb = 0
        end
        if x > 0 && @data[x-1][y] != Tiles::Air
          vl = 0
        end
        if x < @w-1 && @data[x+1][y] != Tiles::Air
          vr = 0
        end
      end
=end
      mv = max(max(vu, vb),max(vl, vr))

      @lightmap[x][y] = max(0, min(32 - @transparency[0] - 1, mv - @transparency[@data[x][y]] + @light[@data[x][y]]))
    end
    if @lightmap[x][y] != v && stack_lvl < 128
      updateLight(x, y+1, stack_lvl + 1)
      updateLight(x, y-1, stack_lvl + 1)
      updateLight(x-1, y, stack_lvl + 1)
      updateLight(x+1, y, stack_lvl + 1)
    end
  end

  def initLight()
    @lightmap = Array.new(@w){Array.new(@h, 0)}
    for i in 0..@w-1
      j = 0
      while @data[i][j+1] == Tiles::Air
        @lightmap[i][j] = 31
        j += 1
      end
    end
    for i in 0..@w-1
      for j in 0..@h-1
        updateLight(i, j, 0)
      end
    end
    for i in 0..@w-1
      for j in 0..@h-1
        updateLight(i, j, 0)
      end
    end
  end

  def check(c, x, y)
    if x < 0 then return 1 end
    if y < 0 then return 1 end
    if x >= @w then return 1 end
    if y >= @h then return 1 end
    return c[x][y] ? 1 : 0
  end
  def generate(width_points, h, sea_lvl, wave_length_pow, nb_oct, amplitude)
    @w = (2 ** wave_length_pow)*width_points
    @h = h
    layers = Array.new(3)
    puts "Generating octaves..."
    layers[0] = Layer.new(Tiles::Grass, sea_lvl, nb_oct, amplitude, wave_length_pow)
    layers[0].generateNew(width_points)
    layers[1] = Layer.new(Tiles::Earth, sea_lvl+1, nb_oct, amplitude, wave_length_pow)
    layers[1].generateOctaves(layers[0].octaves, nb_oct)
    layers[2] = Layer.new(Tiles::Stone, sea_lvl+7, nb_oct, amplitude, wave_length_pow)
    layers[2].generateOctaves(layers[0].octaves, nb_oct - 2)

    puts "Generating terrain..."
    @data = Array.new(@w){Array.new(@h)}

    precomputed = Array.new(layers.size){Array.new(@w)}
    for i in 0..layers.size-1
      for x in 0..@data.size-1
        l = layers[i].base_lvl
        for j in (0..layers[i].octaves.size-1)
          twl = @w / layers[i].octaves[j].size
          a = max(0, x - 1) / twl
          b = min(a + 1, layers[i].octaves[j].size - 1)

          xab = (max(0, x - 1) % twl) / twl.to_f
          l -= interpolate(layers[i].octaves[j][a], layers[i].octaves[j][b], xab)
        end
        precomputed[i][x] = l
      end
    end

    for x in 0..@w-1
      for y in 0..@h-1
        @data[x][y] = Tiles::Air
        for i in 0..layers.size-1
          if y >= precomputed[i][x]
            @data[x][y] = layers[i].material
          end
        end
      end
    end

    puts "Generating caves..."
    pStartH = 43
    pStartL = 48
    birth = 4
    death = 4
    steps = 3

    caves = Array.new(@w){ |i|
      Array.new(@h){ |j|
        $rng.Random(100) >= interpolate(pStartH, pStartL, (j.to_f) / (@h)) ? true : false
      }
    }
    for step in 0..steps
      caves2 = Array.new(@w){Array.new(@h)}
      for i in 0..@w-1
        for j in 0..@h-1
          t = 0
          t += check(caves, i+1, j)
          t += check(caves, i+1, j+1)
          t += check(caves, i, j+1)
          t += check(caves, i-1, j)
          t += check(caves, i-1, j-1)
          t += check(caves, i, j-1)
          t += check(caves, i+1, j-1)
          t += check(caves, i-1, j+1)

          if caves[i][j]
              caves2[i][j] = (t < death ? false : true)
          else
              caves2[i][j] = (t > birth ? true : false)
          end
        end
      end
      caves, caves2 = caves2, caves
    end



    for i in 0..@w-1
      for j in 0..@h-1
        if !caves[i][j]
          @data[i][j] = Tiles::Air
        end
      end
    end


    puts "Calculating lightning..."
    initLight()

    puts "Hiding treasures..."

    nbCoffres = $rng.Random(1000) + 3000
    b = 1
    x = 0
    y = 0
    v = 31
    while nbCoffres > 0
      while b != Tiles::Air || v >= 32 - @transparency[0]
        x = $rng.Random(w)
        y = $rng.Random(h)
        b = @data[x][y]
        v = @lightmap[x][y]
      end
      y -= 1
      while b == Tiles::Air
        y += 1
        b = @data[x][y+1]
      end
      @data[x][y] = Tiles::Chest
      nbCoffres -= 1;
    end
  end

  def getIdTorch(x)
    indices = [0] * 1 + [1] * 1 + [2] * 1 + [3] * 1
    index = indices[Gosu::milliseconds / 300 % indices.size]
    return (x.to_s+index.to_s).to_i
  end

  def draw(posX, posY)
    # Définition des blocs du tableau à draw
    debutX = ((posX / 48) - 34).floor
    debutY = ((posY / 48) - 16).floor

    finX = debutX + 68
    finY = debutY + 32
    # L'index ne peut pas être négatif (min = 0)
    debutX = (debutX < 0)? 0 : debutX
    debutY = (debutY < 0)? 0 : debutY

    # Si on dépasse la taille du tableau on dessine la valeur max (permet d'éviter le out of bound)
    finX = (finX > @w-1)? @w-1 : finX
    finY = (finY > @h-1)? @h-1 : finY

    for i in debutX..finX
      for j in debutY..finY
        if i >= 0 && j >= 0 && @data[i][j] != Tiles::Air && @data[i][j] <80 # S'il ne s'agit pas d'un block d'air
          @images[@data[i][j]].draw($scale*i*(@images[@data[i][j]].width), $scale*j*(@images[@data[i][j]].height), -1, $scale, $scale) # on le dessine en fonction de sa position dans le tableau
          alpha = 255 - (@lightmap[i][j] * 8)
          col = Gosu::Color.new(alpha, 255, 255, 255)

          @shadow.draw($scale*i*(@shadow.width), $scale*j*(@shadow.height), -1, $scale, $scale, col)
        end
        if i >= 0 && j >= 0 && @data[i][j] >=80 &&  @data[i][j] <=103
          @images[getIdTorch(@data[i][j]/10)].draw($scale*i*(@images[getIdTorch(@data[i][j]/10)].width), $scale*j*(@images[getIdTorch(@data[i][j]/10)].height), -1, $scale, $scale) # on le dessine en fonction de sa position dans le tableau

          alpha = 255 - (@lightmap[i][j] * 8)
          col = Gosu::Color.new(alpha, 255, 255, 255)
          @shadow.draw($scale*i*(@shadow.width), $scale*j*(@shadow.height), -1, $scale, $scale, col)
        end
      end
    end
  end

  def ground(x)
    i = 0
    while i < @data[0].size-1 && @data[x][i] == 0 && @data[x+1][i] == 0 do
      i+= 1
    end
    return i
  end

  def solid(x, y)
    #Test pour le bloc du bas gauche/droite et haut gauche/droite s'il est solide
    # On ne peut aussi pas dépasser les limites de la map
    if x < 0 || x > (@data.size-3)*(32*$scale) || y > (@data[0].size-3)*(32*$scale) || @data[x / (32*$scale)][y / (32*$scale)] != 0 || @data[(x+56) / (32*$scale)][y / (32*$scale)] != 0 || @data[x / (32*$scale)][(y-70) / (32*$scale)] !=0 || @data[(x+48) / (32*$scale)][(y) / (32*$scale)] !=0 || @data[(x+56) / (32*$scale)][(y-70) / (32*$scale)] !=0
      return true
    else
      return false
    end
  end

  def trouveBloc(cursor_x,cursor_y,camera_x, camera_y,hero_x,hero_y)

    blocTrouve = false
    cursor_r_x = camera_x+cursor_x
    cursor_r_y = camera_y+cursor_y
    center_x = hero_x + 24
    center_y = hero_y - 70

    #calcul coef directeur
    if ((center_y)-cursor_r_y) - ((center_x)-cursor_r_x) == 0
      c = -9999.0
    elsif ((center_y)-cursor_r_y) + ((center_x)-cursor_r_x) == 0
      c = 9999.0
    else
      c = ((center_y)-cursor_r_y)/((center_x)-cursor_r_x).to_f
    end

    cx = 1
    cy = c
    cl = (cx**2 + cy**2)**0.5

    cx /= cl
    cy /= cl

    bloc_x = center_x / (32*$scale).to_f
    bloc_y = center_y / (32*$scale).to_f

    inc = 0
    while !blocTrouve

      if inc > 5
        return -1, -1
      end

      if cursor_r_x < hero_x
        bloc_x -= cx
        bloc_y -= cy
      else
        bloc_x += cx
        bloc_y += cy
      end
      #puts x.to_s+" . "+ y.to_s

      #puts bloc_x.
      x = bloc_x.floor
      y = bloc_y.floor

      #puts x.to_s+" . "+ y.to_s

      if x>=0 && y>=0 && x<@w && y<@h
        if @data[x][y] != Tiles::Air
          blocTrouve = true
        end
      end

      if x>@w || y>@h
       blocTrouve = true
      end

      inc += 1

    end

    if ((x-(hero_x/(32*$scale)).floor).abs < 5) && ((y-(hero_y/(32*$scale)).floor).abs < 5)
      return x,y
    else
      return -1,-1
    end

  end

  def trouveBlocP(cursor_x,cursor_y,camera_x, camera_y,hero_x,hero_y)

    #puts hero_x.to_s+" . "+hero_y.to_s

    cursor_r_x = camera_x+cursor_x
    cursor_r_y = camera_y+cursor_y

    x = (cursor_r_x/(32*$scale)).floor
    y = (cursor_r_y/(32*$scale)).floor

    #puts cursor_r_y.to_s+" . "+cursor_r_x.to_s

    hero_xb = (hero_x/(32*$scale)).floor
    hero_yb = (hero_y/(32*$scale)).floor

    espaceHero = ((x == hero_xb && y == hero_yb) || (x == hero_xb && y == (hero_yb-1)) || (x == (hero_xb+1) && y == hero_yb) || (x == (hero_xb+1) && y == hero_yb-1))
    blocAdjacent = (@data[x-1][y] != Tiles::Air) || (@data[x+1][y] != Tiles::Air) || (@data[x][y-1] != Tiles::Air) || (@data[x][y+1] != Tiles::Air)

    if espaceHero || !blocAdjacent || @data[x][y] != Tiles::Air
      return -1,-1
    else
      return x,y
    end

  end

  def poserBloc(bloc_x,bloc_y,id)
    if id==80
      if (@data[bloc_x][bloc_y+1] != Tiles::Air)
        setBlock(bloc_x,bloc_y,80)
        puts "Lol"
        return
      end
      if (@data[bloc_x-1][bloc_y] != Tiles::Air)
        puts "G"
        setBlock(bloc_x,bloc_y,100)
        return
      end
      if (@data[bloc_x+1][bloc_y] != Tiles::Air)
        setBlock(bloc_x,bloc_y,90)
        return
      end
      return
    end

    setBlock(bloc_x,bloc_y,id)

  end

  def detruireBloc(bloc_x,bloc_y)
    setBlock(bloc_x,bloc_y,0)
  end

end
