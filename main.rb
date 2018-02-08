require 'gosu'

require_relative 'z_order'
require_relative 'hero'
require_relative 'window'
require_relative 'map'
require_relative 'inventaire'

WindowWidth = Gosu::screen_width()
WindowHeight = Gosu::screen_height()
$rng = RNG.new(Time.now.to_i % 12345)
Window = Window.new(WindowWidth, WindowHeight)
Window.show
