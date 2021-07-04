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

  def createObjects
    (0..(@num_agents - 1)).each do |i|
      location = randomFreeLocation
      agent = Agent.new(self, i, location)
      set_object(location, agent)
      @agents[i] = agent
    end
    (0..(@num_holes - 1)).each do |i|
      createHole(i)
    end
    (0..(@num_tiles - 1)).each do |i|
      createTile(i)
    end
    (0..(@num_obstacles - 1)).each do |i|
      location = randomFreeLocation
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

  def createTile(num)
    score = rand(1..6)
    location = randomFreeLocation
    tile = Tile.new(num, location, score)
    set_object(location, tile)
    @tiles[num] = tile
  end

  def createHole(num)
    location = randomFreeLocation
    hole = Hole.new(num, location)
    set_object(location, hole)
    @holes[num] = hole
  end

  def removeTile(tile)
    @tiles.delete(tile)
    set_object(tile.location, nil)
    createTile(tile.num)
  end

  def removeHole(hole)
    @holes.delete(hole)
    set_object(hole.location, nil)
    createHole(hole.num)
  end

  def validLocation(location)
    location.row >= 0 && location.row < ROWS && location.col >= 0 && location.col < COLS
  end

  def freeLocation(location)
    validLocation(location) && object(location).nil?
  end

  def randomFreeLocation
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

  def getClosestTile(location)
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

  def getClosestHole(location)
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
      origLocation = a.location
      a.update
      puts a
      newLocation = a.location
      set_object(origLocation, nil)
      set_object(newLocation, a)
    end
  end

  def printGrid
    print '  '
    (0..(COLS - 1)).each do |c|
      printf '%d', c % 10
    end
    (0..(ROWS - 1)).each do |r|
      puts
      printf '%02d', r
      (0..(COLS - 1)).each do |c|
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
    end
    puts
    @agents.each do |a|
      id = a.num
      text = "Agent(#{id}): #{a.score}"
      puts text
    end
  end
end
