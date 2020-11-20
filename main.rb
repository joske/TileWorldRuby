#!/usr/bin/env ruby

require './grid.rb'
require './gridview.rb'

ROWS=50
COLS=50
MAG=20

grid = Grid.new(6, 20, 20, 20)
app = TileWorld.new(grid)
app.run