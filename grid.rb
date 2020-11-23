require './objects.rb'

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
    self.col == other.col && self.row == other.row
  end

  def to_s
    "location(#{@col}, #{@row})"
  end
end

class Grid
  def initialize(numAgents, numHoles, numTiles, numObstacles)
    @numAgents = numAgents
    @numHoles = numHoles
    @numTiles = numTiles

    @agents = [] # array, as the number of agents stays fixed
    @holes = Hash.new # hash because holes/tiles appear/disappear 
    @tiles = Hash.new 
    @obstacles = [] # also fixed
    @objects = Hash.new # store as hash, with key the array [col, row] -- Ruby has no real 2d array
    # create agents
    for a in 0..(numAgents - 1)
      location = randomFreeLocation
      Agent.new(self, a, location)
    end
    for a in 0..(numHoles - 1)
      createHole(a)
    end
    for a in 0..(numTiles - 1)
      createTile(a)
    end
    for a in 0..(numObstacles - 1)
      location = randomFreeLocation
      Obstacle.new(self, a, location)
    end
  end

  def objects
    @objects
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

  def obstacles
    @obstacles
  end

  def createTile(a)
    score = rand(1..6)
    location = randomFreeLocation
    Tile.new(self, a, location, score)
  end

  def createHole(a)
    location = randomFreeLocation
    hole = Hole.new(self, a, location)
  end

  def removeTile(tile)
    @tiles.delete(tile.num)
    @objects[[tile.col, tile.row]] = nil
    createTile(tile.num)
  end

  def removeHole(hole)
    @holes.delete(hole.num)
    @objects[[hole.col, hole.row]] = nil
    createHole(hole.num)
  end

  def freeLocation(location)
    @objects[[location.col, location.row]] == nil
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
    while @objects[[col, row]] != nil
      col = rand(0..COLS - 1)
      row = rand(0..ROWS - 1)
    end
    location = Location.new(col, row)
    return location
  end

  def distance(location1, location2)
    return (location1.col - location2.col).abs + (location1.row - location2.row).abs
  end

  def getClosestTile(location)
    closest = 1000000
    best = nil
    @tiles.each_value { |t|
      dist = distance(location, t.location)
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
      dist = distance(location, h.location)
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
      @objects[[origLocation.col, origLocation.row]] = nil
      @objects[[newLocation.col, newLocation.row]] = a
    }
  end
end
