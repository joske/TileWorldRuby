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

  def getDirection(other)
    if @row == other.row
      if @col == other.col + 1
        return Direction::LEFT
      else
        return Direction::RIGHT
      end
    else
      if @row == other.row + 1
        return Direction::UP
      else
        return Direction::DOWN
      end
    end
  end

  def to_s
    "location(#{@col}, #{@row})"
  end
end

class Grid
  def initialize # unit test
    @numAgents = 0
    @numHoles = 0
    @numTiles = 0
    @agents = [] # array, as the number of agents stays fixed
    @holes = Hash.new # hash because holes/tiles appear/disappear
    @tiles = Hash.new
    @obstacles = [] # also fixed
    @objects = Hash.new # store as hash, with key the array [col, row] -- Ruby has no real 2d array
  end

  def initialize(numAgents, numHoles, numTiles, numObstacles)
    @numAgents = numAgents
    @numHoles = numHoles
    @numTiles = numTiles
    @numObstacles = numObstacles

    @agents = [] # array, as the number of agents stays fixed
    @holes = Hash.new # hash because holes/tiles appear/disappear
    @tiles = Hash.new
    @obstacles = [] # also fixed
    @objects = Hash.new # store as hash, with key the array [col, row] -- Ruby has no real 2d array
  end

  def createObjects
    # create agents
    for a in 0..(@numAgents - 1)
      location = randomFreeLocation
      @objects[location] = Agent.new(self, a, location)
    end
    for a in 0..(@numHoles - 1)
      createHole(a)
    end
    for a in 0..(@numTiles - 1)
      createTile(a)
    end
    for a in 0..(@numObstacles - 1)
      location = randomFreeLocation
      @objects[location] = Obstacle.new(self, a, location)
    end
  end

  def agents
    @agents
  end

  def tiles
    @tiles
  end

  def holes
    @holes
  end

  def object(location)
    return @objects[location]
  end

  def obstacles
    @obstacles
  end

  def createTile(a)
    score = rand(1..6)
    location = randomFreeLocation
    @objects[location] = Tile.new(self, a, location, score)
  end

  def createHole(a)
    location = randomFreeLocation
    @objects[location] = Hole.new(self, a, location)
  end

  def removeTile(tile)
    @tiles.delete(tile.num)
    @objects[tile.location] = nil
    createTile(tile.num)
  end

  def removeHole(hole)
    @holes.delete(hole.num)
    @objects[hole.location] = nil
    createHole(hole.num)
  end

  def freeLocation(location)
    object(location) == nil
  end

  def validMove(location, dir)
    if (dir == Direction::UP)
      return location.row > 0 && freeLocation(location.nextLocation(dir))
    elsif (dir == Direction::DOWN)
      return location.row < ROWS - 1 && freeLocation(location.nextLocation(dir))
    elsif (dir == Direction::LEFT)
      return location.col > 0 && freeLocation(location.nextLocation(dir))
    else
      return location.col < COLS - 1 && freeLocation(location.nextLocation(dir))
    end
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
      @objects[origLocation] = nil
      @objects[newLocation] = a
    }
  end

  def printGrid
    for r in 0..(ROWS - 1)
      puts
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
  end
end
