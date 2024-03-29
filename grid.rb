require_relative 'objects'

module Direction
  UP = 1
  DOWN = 2
  LEFT = 3
  RIGHT = 4
end

class Location
  def initialize(col, row)
    @col = col
    @row = row
  end

  attr_reader :row, :col

  def next_location(dir)
    if dir == Direction::UP
      Location.new(@col, @row - 1)
    elsif dir == Direction::DOWN
      Location.new(@col, @row + 1)
    elsif dir == Direction::LEFT
      Location.new(@col - 1, @row)
    else
      Location.new(@col + 1, @row)
    end
  end

  def equal?(other)
    @col == other.col && @row == other.row
  end

  def ==(other)
    @col == other.col && @row == other.row
  end

  def eql?(other)
    @col == other.col && @row == other.row
  end

  def hash
    @col << 8 & @row.hash
  end

  def distance(other)
    (col - other.col).abs + (row - other.row).abs
  end

  def to_s
    "location(#{@col}, #{@row})"
  end
end

# Grid class -> keeps the grid & pointers to all objects
class Grid
  attr_reader :agents

  def initialize(num_agents = 0, num_holes = 0, num_tiles = 0, num_obstacles = 0)
    @num_agents = num_agents
    @num_holes = num_holes
    @num_tiles = num_tiles
    @num_obstacles = num_obstacles

    @agents = [] # array, as the number of agents stays fixed
    @holes = {} # hash because holes/tiles appear/disappear
    @tiles = {}
    @obstacles = [] # also fixed
    @objects = Array.new(COLS) { Array.new(ROWS) { nil } }
  end

  def create_objects
    (0..(@num_agents - 1)).each do |i|
      location = random_free_location
      agent = Agent.new(self, i, location)
      set_object(location, agent)
      @agents[i] = agent
    end
    (0..(@num_holes - 1)).each do |i|
      create_hole(i)
    end
    (0..(@num_tiles - 1)).each do |i|
      create_tile(i)
    end
    (0..(@num_obstacles - 1)).each do |i|
      location = random_free_location
      obst = Obstacle.new(i, location)
      set_object(location, obst)
      @obstacles[i] = obst
    end
  end

  def object(location)
    raise "Alles kapot: column out of range: #{location.col}" if location.col > COLS - 1 || location.col < 0
    raise "Alles kapot: row out of range: #{location.row}" if location.row > ROWS - 1 || location.row < 0

    @objects[location.col][location.row]
  end

  def set_object(location, o)
    @objects[location.col][location.row] = o
  end

  def create_tile(num)
    score = rand(1..6)
    location = random_free_location
    tile = Tile.new(num, location, score)
    set_object(location, tile)
    @tiles[num] = tile
  end

  def create_hole(num)
    location = random_free_location
    hole = Hole.new(num, location)
    set_object(location, hole)
    @holes[num] = hole
  end

  def remove_tile(tile)
    @tiles.delete(tile)
    set_object(tile.location, nil)
    create_tile(tile.num)
  end

  def remove_hole(hole)
    @holes.delete(hole)
    set_object(hole.location, nil)
    create_hole(hole.num)
  end

  def valid_location(location)
    location.row >= 0 && location.row < ROWS && location.col >= 0 && location.col < COLS
  end

  def free_location(location)
    valid_location(location) && object(location).nil?
  end

  def random_free_location
    col = rand(0..COLS - 1)
    row = rand(0..ROWS - 1)
    location = Location.new(col, row)
    until object(location).nil?
      col = rand(0..COLS - 1)
      row = rand(0..ROWS - 1)
      location = Location.new(col, row)
    end
    location
  end

  def get_closest_tile(location)
    closest = 1_000_000
    best = nil
    @tiles.each_value do |t|
      dist = location.distance(t.location)
      if dist < closest
        closest = dist
        best = t
      end
    end
    best
  end

  def get_closest_hole(location)
    closest = 1_000_000
    best = nil
    @holes.each_value do |h|
      dist = location.distance(h.location)
      if dist < closest
        closest = dist
        best = h
      end
    end
    best
  end

  def update
    @agents.each do |a|
      puts a
      orig = a.location
      a.update
      puts a
      new_loc = a.location
      set_object(orig, nil)
      set_object(new_loc, a)
    end
    print_grid
  end

  def print_grid
    print_header
    (0..(ROWS - 1)).each do |r|
      puts
      printf '%02d', r # print row number
      (0..(COLS - 1)).each do |c|
        print_row(c, r)
      end
    end
    puts
    @agents.each do |a|
      id = a.num
      text = "Agent(#{id}): #{a.score}"
      puts text
    end
  end
end

# print column numbers
def print_header
  print '  '
  (0..(COLS - 1)).each do |c|
    printf '%d', c % 10
  end
end

def print_row(c, r)
  location = Location.new(c, r)
  o = object(location)
  if !o.nil?
    if o.instance_of? Agent
      print 'A'
    elsif o.instance_of? Hole
      print 'H'
    elsif o.instance_of? Tile
      print 'T'
    elsif o.instance_of? Obstacle
      print '#'
    end
  else
    print '.'
  end
end
