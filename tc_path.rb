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
    agent = Agent.new(grid, 0, Location.new(0, 0))
    tile = Tile.new(0, Location.new(2, 1), 1)
    path = shortestPath(grid, agent.location, tile.location)
    puts "from #{agent.location} to #{tile.location} : #{path}"
    path.each { |dir|
      agent.nextMove(dir)
    }
    assert_equal(agent.location, tile.location)
  end

  # def testAstarSearch
  #   grid = Grid.new(1, 0, 1, 0)
  #   agent = Agent.new(grid, 0, Location.new(0, 0))
  #   tile = Tile.new(grid, 0, Location.new(2, 1), 1)
  #   path = astar_search(grid, agent.location, tile.location)
  #   puts "from #{agent.location} to #{tile.location} : #{path}"
  #   path.each { |dir|
  #     agent.nextMove(dir)
  #   }
  #   assert_equal(agent.location, tile.location)
  # end

  def testLocationEquals
    first = Location.new(1, 2)
    second = Location.new(1, 2)
    assert_equal(first, second)
    assert_equal(first.hash, second.hash)
    map = Hash.new()
    map[first] = first
    assert_equal(first, map[first])
    assert_not_nil(map[first])
    assert_not_nil(map[second])
    assert(first == second)
  end
end
