#!/usr/bin/env ruby
require_relative 'astar'
require_relative 'grid'

require 'test/unit'

COLS = 5
ROWS = 5

# unit test for astar
class TestPath < Test::Unit::TestCase
  def test_search
    grid = Grid.new
    from = Location.new(0, 0)
    to = Location.new(1, 1)
    path = astar(grid, from, to)
    puts "from #{from} to #{to} : #{path}"
    assert_equal(2, path.size)
    assert_equal(Location.new(0, 1), path[0])
    assert_equal(Location.new(1, 1), path[1])
  end

  def test_search2
    # S....
    # ####.
    # .....
    # .....
    # ....E
    grid = Grid.new
    from = Location.new(0, 0)
    to = Location.new(4, 4)
    obstacles = [Obstacle.new(0, Location.new(0, 1)), Obstacle.new(1, Location.new(1, 1)),
                 Obstacle.new(2, Location.new(2, 1)), Obstacle.new(3, Location.new(3, 1))]
    obstacles.each do |obst|
      grid.set_object(obst.location, obst)
    end
    path = astar(grid, from, to)
    puts "from #{from} to #{to} : #{path}"
    assert_equal(8, path.size)
    assert_equal(Location.new(1, 0), path[0])
    assert_equal(Location.new(2, 0), path[1])
    assert_equal(Location.new(3, 0), path[2])
    assert_equal(Location.new(4, 0), path[3])
    assert_equal(Location.new(4, 1), path[4])
    assert_equal(Location.new(4, 2), path[5])
    assert_equal(Location.new(4, 3), path[6])
    assert_equal(Location.new(4, 4), path[7])
  end

  def test_search3
    # S....
    # #####
    # .....
    # .....
    # ....E
    grid = Grid.new
    from = Location.new(0, 0)
    to = Location.new(4, 4)
    obstacles = [Obstacle.new(0, Location.new(0, 1)), Obstacle.new(1, Location.new(1, 1)),
                 Obstacle.new(2, Location.new(2, 1)), Obstacle.new(3, Location.new(3, 1)), 
                 Obstacle.new(4, Location.new(4, 1))]
    obstacles.each do |obst|
      grid.set_object(obst.location, obst)
    end
    path = astar(grid, from, to)
    puts "from #{from} to #{to} : #{path}"
    assert_equal(0, path.size) # can not reach goal
  end
end
