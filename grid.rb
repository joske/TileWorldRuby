require_relative "objects"

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

  def row
    @row
  end

  def col
    @col
  end

  def nextLocation(dir)
    if (dir == Direction::UP)
      return Location.new(@col, @row - 1)
    elsif (dir == Direction::DOWN)
      return Location.new(@col, @row + 1)
    elsif (dir == Direction::LEFT)
      return Location.new(@col - 1, @row)
    else
      return Location.new(@col + 1, @row)
    end
  end

  def equal?(other)
    return @col == other.col && @row == other.row
  end

  def ==(other)
    return @col == other.col && @row == other.row
  end

  def eql?(other)
    return @col == other.col && @row == other.row
  end

  def hash
    return @col << 8 & @row.hash
  end

  def distance(other)
    return (self.col - other.col).abs + (self.row - other.row).abs
  end

  def to_s
    "location(#{@col}, #{@row})"
  end
end

class Grid
  attr_reader :agents

  def initialize(numAgents = 0, numHoles = 0, numTiles = 0, numObstacles = 0)
    @numAgents = numAgents
    @numHoles = numHoles
    @numTiles = numTiles
    @numObstacles = numObstacles

    @agents = [] # array, as the number of agents stays fixed
    @holes = Hash.new # hash because holes/tiles appear/disappear
    @tiles = Hash.new
    @obstacles = [] # also fixed
    @objects = Array.new(COLS) { Array.new(ROWS) { nil } }
  end

  def createObjects
    for i in 0..(@numAgents - 1)
      location = randomFreeLocation
      agent = Agent.new(self, i, location)
      set_object(location, agent)
      @agents[i] = agent
    end
    for i in 0..(@numHoles - 1)
      createHole(i)
    end
    for i in 0..(@numTiles - 1)
      createTile(i)
    end
    for i in 0..(@numObstacles - 1)
      location = randomFreeLocation
      obst = Obstacle.new(i, location)
      set_object(location, obst)
      @obstacles[i] = obst
    end
  end

  def object(location)
    if location.col > COLS - 1 || location.col < 0
      raise "Alles kapot: column out of range: #{location.col}"
    end
    if location.row > ROWS - 1 || location.row < 0
      raise "Alles kapot: row out of range: #{location.row}"
    end
    return @objects[location.col][location.row]
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
    return location.row >= 0 && location.row < ROWS && location.col >= 0 && location.col < COLS
  end

  def freeLocation(location)
    validLocation(location) && object(location).nil?
  end

  def randomFreeLocation
    col = rand(0..COLS - 1)
    row = rand(0..ROWS - 1)
    location = Location.new(col, row)
    while object(location) != nil
      col = rand(0..COLS - 1)
      row = rand(0..ROWS - 1)
      location = Location.new(col, row)
    end
    return location
  end

  def getClosestTile(location)
    closest = 1000000
    best = nil
    @tiles.each_value { |t|
      dist = location.distance(t.location)
      if dist < closest
        closest = dist
        best = t
      end
    }
    return best
  end

  def getClosestHole(location)
    closest = 1000000
    best = nil
    @holes.each_value { |h|
      dist = location.distance(h.location)
      if dist < closest
        closest = dist
        best = h
      end
    }
    return best
  end

  def update
    @agents.each() { |a|
      puts a
      origLocation = a.location
      a.update
      puts a
      newLocation = a.location
      set_object(origLocation, nil)
      set_object(newLocation, a)
    }
  end

  def printGrid
    print "  "
    for c in 0..(COLS - 1)
      printf "%d", c % 10
    end
    for r in 0..(ROWS - 1)
      puts
      printf "%02d", r
      for c in 0..(COLS - 1)
        location = Location.new(c, r)
        o = object(location)
        if o != nil
          if o.instance_of? Agent
            print "A"
          elsif o.instance_of? Hole
            print "H"
          elsif o.instance_of? Tile
            print "T"
          elsif o.instance_of? Obstacle
            print "#"
          end
        else
          print "."
        end
      end
    end
    puts
    @agents.each { |a|
      id = a.num
      text = "Agent(#{id}): #{a.score}"
      puts text
    }
  end
end
