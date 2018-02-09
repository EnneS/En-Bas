require 'gosu'

require_relative 'z_order'
require_relative 'hero'
require_relative 'window'
require_relative 'map'
require_relative 'inventaire'
require_relative 'monstre'

WindowWidth = 1920
WindowHeight = 1080
$rng = RNG.new(Time.now.to_i)
Window = Window.new(WindowWidth, WindowHeight)
Window.show
