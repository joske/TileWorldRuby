#!/usr/bin/env ruby

require "./grid.rb"
require "./gridview.rb"
require "./objects.rb"

ROWS = 40
COLS = 40
MAG = 20
RANDOM_MOVE_PERC=20
TIMEOUT=200

grid = Grid.new(6, 20, 20, 20)
app = TileWorld.new(grid)
app.run
