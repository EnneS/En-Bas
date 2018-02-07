require 'pp'

module Tiles
  Air = 0
  Grass = 1
  Earth = 2
  Stone = 3
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
    @m = 2**31
    @a = 1103515245
    @c = 12345
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
        octaves[y][x] = $rng.GenerateKeyPoint(amplitude / (1.5 ** y))

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
          @octaves[j][i] = $rng.GenerateKeyPoint(amplitude / (1.5**j))
        end
      end
    end
  end

end


class Map

  attr_reader :data, :images

  def initialize()
    @images = Array.new(4)
    @images[0] = 0 # air
    @images[1] = Gosu::Image.new("res/tiles/grass.png")
    @images[2] = Gosu::Image.new("res/tiles/dirt.png")
    @images[3] = Gosu::Image.new("res/tiles/stone.png")

  end

  def setBlock(x, y, v)
    o = @data[x][y]
    @data[x][y] = v
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

  def load()
    File.open("terrain.map") do |file|
      @data = Marshal.load(file)
    end
  end
  def check(c, x, y, w, h)
    if x < 0 then return 1 end
    if y < 0 then return 1 end
    if x >= w then return 1 end
    if y >= h then return 1 end
    return c[x][y] ? 1 : 0
  end
  def generate(width_points, h, sea_lvl, wave_length_pow, nb_oct, amplitude)
    w = (2 ** wave_length_pow)*width_points
    layers = Array.new(3)
    puts "Generating octaves"
    layers[0] = Layer.new(Tiles::Grass, sea_lvl, nb_oct, amplitude, wave_length_pow)
    layers[0].generateNew(width_points)
    layers[1] = Layer.new(Tiles::Earth, sea_lvl+1, nb_oct, amplitude, wave_length_pow)
    layers[1].generateOctaves(layers[0].octaves, nb_oct)
    layers[2] = Layer.new(Tiles::Stone, sea_lvl+5, nb_oct, amplitude, wave_length_pow)
    layers[2].generateOctaves(layers[0].octaves, nb_oct - 3)

    puts "Generating terrain"
    @data = Array.new(w){Array.new(h)}

    precomputed = Array.new(layers.size){Array.new(w)}
    for i in 0..layers.size-1
      for x in 0..@data.size-1
        l = layers[i].base_lvl
        for j in (0..layers[i].octaves.size-1)
          twl = w / layers[i].octaves[j].size
          a = max(0, x - 1) / twl
          b = min(a + 1, layers[i].octaves[j].size - 1)

          xab = (max(0, x - 1) % twl) / twl.to_f
          l -= interpolate(layers[i].octaves[j][a], layers[i].octaves[j][b], xab)
        end
        precomputed[i][x] = l
      end
    end

    for x in 0..w-1
      for y in 0..h-1
        @data[x][y] = Tiles::Air
        for i in 0..layers.size-1
          if y >= precomputed[i][x]
            @data[x][y] = layers[i].material
          end
        end
      end
    end

    puts "Generating caves"
    pStartH = 38
    pStartL = 48
    birth = 4
    death = 4
    steps = 3

    caves = Array.new(w){ |i|
      Array.new(h){ |j|
        $rng.Random(100) >= interpolate(pStartH, pStartL, j.to_f / h) ? true : false
      }
    }
    for step in 0..steps
      caves2 = Array.new(w){Array.new(h)}
      for i in 0..w-1
        for j in 0..h-1
          t = 0
          t += check(caves, i+1, j, w, h)
          t += check(caves, i+1, j+1, w, h)
          t += check(caves, i, j+1, w, h)
          t += check(caves, i-1, j, w, h)
          t += check(caves, i-1, j-1, w, h)
          t += check(caves, i, j-1, w, h)
          t += check(caves, i+1, j-1, w, h)
          t += check(caves, i-1, j+1, w, h)

          if caves[i][j]
              caves2[i][j] = (t < death ? false : true)
          else
              caves2[i][j] = (t > birth ? true : false)
          end
        end
      end
      caves, caves2 = caves2, caves
=begin
      for i in 0..w-1
        for j in 0..h-1
          caves[i][j] = caves2[i][j]
        end
      end
=end
    end



    for i in 0..w-1
      for j in 0..h-1
        if !caves[i][j]
          @data[i][j] = Tiles::Air
        end
      end
    end


    File.open("terrain.map", "w+") do |file|
      Marshal.dump(@data, file)
    end
    puts 4
end

def draw(posX, posY)
  # Définition des blocs du tableau à draw
  debutX = (posX / 60) - 25
  debutY = (posY / 60) - 16
  finX = debutX + 50
  finY = debutY + 32

  # L'index ne peut pas être négatif (min = 0)
  debutX = (debutX < 0)? 0 : debutX
  debutY = (debutY < 0)? 0 : debutY

  # Si on dépasse la taille du tableau on dessine la valeur max (permet d'éviter le out of bound)
  finX = (finX > @data.size-1)? @data.size-1 : finX
  finY = (finY > @data[0].size-1)? @data[0].size-1 : finY

  for i in debutX..finX
    for j in debutY..finY
      if i >= 0 && j >= 0 && @data[i][j] != Tiles::Air # S'il ne s'agit pas d'un block d'air
        @images[@data[i][j]].draw(2*i*(@images[@data[i][j]].width - 2), 2*j*(@images[@data[i][j]].height - 2), -1, 2, 2) # on le dessine en fonction de sa position dans le tableau
      end
    end
  end
end

  def ground(x)
    i = 0
    while i < @data[0].size-1 && @data[x][i] == 0 do
      i+= 1
    end
    return i
  end

  def update(i, j, state)
    @data[i][j] = state
  end

  def solid(x, y)
    #Test pour le bloc du bas gauche/droite et haut gauche/droite s'il est solide
    # On ne peut aussi pas dépasser les limites de la map
    if x < 0 || x > (@data.size-1)*(30*2) || @data[x / (30*2)][y / (30*2)] != 0 || @data[((x+58) / (30*2))][y / (30*2)] != 0 || @data[x / (30*2)][(y-64) / (30*2)] !=0 || @data[((x+58) / (30*2))][(y-64) / (30*2)] != 0
      return true
    else
      return false
    end
  end


  def trouveBloc(cursor_x,cursor_y,camera_x, camera_y,hero_x,hero_y)

    #valeur de z
    #0 => poser
    #1 => casser

    blocTrouve = false
    cursor_r_x = camera_x+cursor_x
    cursor_r_y = camera_y+cursor_y
    bloc_x = hero_x
    bloc_y = hero_y
    x = 0
    y = 0

    #calcul coef directeur
    c = ((hero_y)-cursor_r_y)/((hero_x)-cursor_r_x)

    while !blocTrouve

      if cursor_r_x < hero_x
        bloc_x-=1
        bloc_y+= -(c)
      else
        bloc_x+=1
        bloc_y+=(c)
<<<<<<< HEAD
      end 
=======
      end

>>>>>>> 965ebc76be41399b110646341216d68690fba7be

      xlast = x
      ylast = y
     
      x = (bloc_x/60).floor
      y = (bloc_y/60).floor

      if @data[x][y] != Tiles::Air
        blocTrouve = true
      end
    end

    return x,y
<<<<<<< HEAD
  
  end 
=======

  end
>>>>>>> 965ebc76be41399b110646341216d68690fba7be

  def trouveBloc(cursor_x,cursor_y,camera_x, camera_y,hero_x,hero_y,z)

    cursor_r_x = camera_x+cursor_x
    cursor_r_y = camera_y+cursor_y
    #bloc_x = hero_x+30
    #bloc_y = hero_y-60

    x = (cursor_r_x/60).floor
    y = (cursor_r_y/60).floor

    return x,y

  end


  def poserBloc(bloc_x,bloc_y,id)
    #puts id.to_s
    setBlock(bloc_x,bloc_y,id)
  end

  def detruireBloc(bloc_x,bloc_y)
    setBlock(bloc_x,bloc_y,0)
  end
end
