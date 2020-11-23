require_relative "path.rb"
require_relative "grid.rb"

require "test/unit"

COLS = 5
ROWS = 5

class TestPath < Test::Unit::TestCase
  def testSearch
    grid = Grid.new(1, 0, 1, 0)
    agent = Agent.new(grid, 0, Location.new(0, 0))
    tile = Tile.new(grid, 0, Location.new(1, 0), 1)
    path = shortestPath(grid, agent.location, tile.location)
    puts "from #{agent.location} to #{tile.location} : #{path}"
  end
end
