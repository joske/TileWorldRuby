#!/usr/bin/env ruby

require_relative 'grid'
require_relative 'gridview'
require_relative 'objects'

ROWS = 40
COLS = 40
MAG = 20
TIMEOUT = 200

grid = Grid.new(6, 20, 20, 40)
grid.create_objects
app = TileWorld.new(grid)
app.run
