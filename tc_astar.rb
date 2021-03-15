#!/usr/bin/env ruby
require_relative "path.rb"
require_relative "astar.rb"
require_relative "grid.rb"

require "test/unit"

COLS = 5
ROWS = 5

class TestPath < Test::Unit::TestCase
    def testSearch
      grid = Grid.new
      from = Location.new(0,0)
      to = Location.new(1, 1)
      path = astar(grid, from, to)
      puts "from #{from} to #{to} : #{path}"
      assert_equal(2, path.size)
      assert_equal(Direction::DOWN, path[0])
      assert_equal(Direction::RIGHT, path[1])
    end
end