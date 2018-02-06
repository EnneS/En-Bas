require 'gosu'

require_relative 'z_order'
require_relative 'hero'
require_relative 'window'
require_relative 'map'

WindowWidth = 1920
WindowHeight = 1080
$rng = RNG.new(Time.now.to_i % 12345)
Window = Window.new(WindowWidth, WindowHeight)
<<<<<<< HEAD
Window.show
=======
Window.show
>>>>>>> 4007a36b43a36d3e493856ed73727222e470eab2
