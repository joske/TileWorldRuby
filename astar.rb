require 'rubygems'
require 'algorithms'
require 'set'

# node holder
class Node
  attr_accessor :location, :score, :path

  def initialize(l, p, s)
    @location = l
    @path = p
    @score = s
  end

  def ==(other)
    @location.equal?(other.location)
  end

  def <=>(other)
    @score <=> other.score
  end

  def to_s
    "Node(@#{@location}, path=#{@path}, score=#{@score})"
  end
end

def astar(grid, from, to)
  open_list = Containers::PriorityQueue.new do |x, y|
    (y <=> x) == 1
  end
  open_set = Set.new
  closed_list = Set.new
  fromNode = Node.new(from, nil, 0)
  open_list.push(fromNode, 0)
  open_set.add(fromNode)
  until open_list.empty?
    current = open_list.pop
    puts "current=#{current}"
    if current.location == to
      # arrived
      return current.path
    end
    closed_list.add(current)
    checkNeighbor(grid, open_list, open_set, closed_list, current, Direction::UP, from, to)
    checkNeighbor(grid, open_list, open_set, closed_list, current, Direction::DOWN, from, to)
    checkNeighbor(grid, open_list, open_set, closed_list, current, Direction::LEFT, from, to)
    checkNeighbor(grid, open_list, open_set, closed_list, current, Direction::RIGHT, from, to)
  end
  return []
end

def checkNeighbor(grid, open_list, open_set, closed_list, current, direction, from, to)
  puts "check #{direction}"
  nextLocation = current.location.nextLocation(direction)
  if grid.freeLocation(nextLocation) || nextLocation.equal?(to)
    h = nextLocation.distance(to)
    g = current.location.distance(from) + 1
    path = []
    path.append(*current.path).append(nextLocation)
    child = Node.new(nextLocation, path, g + h)
    unless closed_list.include?(child)
      better = open_set.filter do |n|
        n.location.equal?(child.location) && n.score < child.score
      end
      if better.empty?
        puts "adding child #{child}"
        open_list.push(child, child.score)
        open_set.add(child)
      end
    end
  end
end
