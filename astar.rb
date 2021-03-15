require 'rubygems'
require 'algorithms'

# node holder
class Node
  def initialize(l, p, s)
    @location = l
    @parent = p
    @score = s
  end
  def location
    @location
  end
  def score
    @score
  end
  def parent
    @parent
  end
  def <=>(other)
    @score <=> other.score
  end

  def to_s
    "Node(@#{@location}, parent=#{@parent}, score=#{@score})"
  end
end

def astar(grid, from, to)
  open_list = Containers::PriorityQueue.new { |x, y|
    (y <=> x) == 1
  }
  closed_list = Set.new
  fromNode = Node.new(from, nil, 0)
  open_list.push(fromNode, 0)
  until open_list.empty?
    current = open_list.pop
    puts "current=#{current}"
    if current.location == to
      # arrived
      return makePath(current, fromNode)
    end
    closed_list.add(current)
    checkNeighbor(grid, open_list, closed_list, current, Direction::UP, from, to)
    checkNeighbor(grid, open_list, closed_list, current, Direction::DOWN, from, to)
    checkNeighbor(grid, open_list, closed_list, current, Direction::LEFT, from, to)
    checkNeighbor(grid, open_list, closed_list, current, Direction::RIGHT, from, to)
  end
end

def checkNeighbor(grid, open_list, closed_list, current, direction, from, to)
    puts "check #{direction}"
  nextLocation = current.location.nextLocation(direction)
  if grid.validMove(current.location, direction) || nextLocation.equal?(to)
    h = nextLocation.distance(to)
    g = current.location.distance(from) + 1
    child = Node.new(nextLocation, current, g + h)
    if (!closed_list.include?(child))
        puts "adding child #{child}"
        open_list.push(child, child.score)
    end
    
  end
end

def makePath(endNode, fromNode)
    puts "makePath #{endNode} <- #{fromNode}"
  directions = []
  current = endNode
  parent = endNode.parent
  until current.location.equal?(fromNode.location)
    dir = parent.location.getDirection(current.location)
    directions.unshift(dir)
    current = parent
    parent = current.parent
  end
  return directions
end
