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
  from_node = Node.new(from, nil, 0)
  open_list.push(from_node, 0)
  open_set.add(from_node)
  until open_list.empty?
    current = open_list.pop
    puts "current=#{current}"
    if current.location == to
      # arrived
      return current.path
    end

    closed_list.add(current)
    check_neighbor(grid, open_list, open_set, closed_list, current, Direction::UP, from, to)
    check_neighbor(grid, open_list, open_set, closed_list, current, Direction::DOWN, from, to)
    check_neighbor(grid, open_list, open_set, closed_list, current, Direction::LEFT, from, to)
    check_neighbor(grid, open_list, open_set, closed_list, current, Direction::DOWN, from, to)
    check_neighbor(grid, open_list, open_set, closed_list, current, Direction::RIGHT, from, to)
  end
  []
end

def check_neighbor(grid, open_list, open_set, closed_list, current, direction, from, to)
  puts "check #{direction}"
  next_location = current.location.next_location(direction)
  return unless grid.freeLocation(next_location) || next_location.equal?(to)

  h = next_location.distance(to)
  g = current.location.distance(from) + 1
  path = []
  path.append(*current.path).append(next_location)
  child = Node.new(next_location, path, g + h)

  return if closed_list.include?(child)

  better = open_set.filter do |n|
    n.location.equal?(child.location) && n.score < child.score
  end
  return unless better.empty?

  puts "adding child #{child}"
  open_list.push(child, child.score)
  open_set.add(child)
end
