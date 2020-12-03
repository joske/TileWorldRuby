require_relative "path"

module State
  IDLE = 0
  MOVE_TO_TILE = 1
  MOVE_TO_HOLE = 2
end

class GridObject
  def initialize(grid, num, location)
    @num = num
    @grid = grid
    @location = location
  end

  def num
    @num
  end

  def location
    @location
  end

  def col
    @location.col
  end

  def row
    @location.row
  end

  def equal?(other)
    return @num == other.num && @location == other.location && self.class == other.class
  end

  def to_s
    return "#{self.class.name} #{@num} at #{location}"
  end
end

class Agent < GridObject
  def initialize(grid, num, location)
    super grid, num, location
    grid.agents[num] = self
    @state = State::IDLE
    @tile = nil
    @hole = nil
    @score = 0
    @path = []
    @hasTile = false
  end

  def set_score(score)
    @score = score
  end

  def score
    @score
  end

  # updates the location of this agent
  def nextMove(dir)
    puts "move #{dir}"
    @location = @location.nextLocation(dir)
  end

  def location()
    @location
  end

  def hasTile
    @hasTile
  end

  def set_tile(tile)
    @tile = tile
  end

  def tile
    @tile
  end

  def update
    if @state == State::IDLE
      idle
    elsif @state == State::MOVE_TO_TILE
      moveToTile
    else
      moveToHole
    end
  end

  def idle
    @tile = nil
    @hole = nil
    @hasTile = false
    puts "#{self} finding tile"
    @tile = @grid.getClosestTile(@location)
    puts "#{self} found tile #{@tile}"
    @state = State::MOVE_TO_TILE
  end

  def moveToTile
    if @tile.location.equal? self.location
      # we have arrived
      pickTile
      @hole = @grid.getClosestHole(@location)
      @state = State::MOVE_TO_HOLE
      return
    end
    # check if our tile is still there
    if !@grid.object(@tile.location).equal?(@tile)
      @state = State::IDLE
      return
    end
    # try to find a closer tile
    potentialTile = @grid.getClosestTile(@location)
    if !potentialTile.equal?(@tile)
      @tile = potentialTile
    end
    if @path.empty?
      @path = shortestPath(@grid, self.location, @tile.location)
      puts "#{self} path: #{@path}"
    else
      dir = @path.shift
      nextMove(dir)
    end
    # best_dir = findBestMove(@tile.location)
    # if best_dir != 0
    #   nextMove(best_dir)
    # end
  end

  def pickTile
    puts "agent #{@num}: pickTile"
    @hasTile = true
    @grid.removeTile(@tile)
  end

  def findBestMove(location)
    r = rand(1..100)
    if (r <= RANDOM_MOVE_PERC)
      # RANDOM_MOVE_PERC % chance to pick a random move to get out of local minima
      dir = rand(1..4)
      while !@grid.validMove(@location, dir)
        dir = rand(1..4)
      end
      if @grid.validMove(@location, dir)
        return dir
      end
    end
    min_dist = 100000
    best_dir = 0
    for dir in 1..4
      newLocation = @location.nextLocation(dir)
      if newLocation.equal? location
        #arrived
        return dir
      end
      if @grid.freeLocation(newLocation)
        dist = location.distance(newLocation)
        if dist < min_dist
          min_dist = dist
          best_dir = dir
        end
      end
    end
    return best_dir
  end

  def moveToHole
    if @location.equal? @hole.location
      # we have arrived
      dumpTile
      return
    end
    # check if our hole is still there
    if !@grid.object(@hole.location).equal?(@hole)
      @hole = @grid.getClosestHole(@location)
      return
    end
    # try to find a closer hole
    potentialHole = @grid.getClosestHole(@location)
    if !potentialHole.equal?(@hole)
      @hole = potentialHole
    end
    best_dir = findBestMove(@hole.location)
    if best_dir != 0
      nextlocation = @location.nextLocation(best_dir)
      nextMove(best_dir)
    end
  end

  def dumpTile
    puts "agent #{@num}: dumpTile"
    @score += @tile.score
    @tile = nil
    @hasTile = false
    @grid.removeHole(@hole)
    @hole = nil
    @state = State::IDLE
  end

  def to_s
    return "Agent #{@num} at #{@location} in state #{@state} hasTile=#{@hasTile} tile=#{@tile} hole=#{@hole}"
  end
end

class Hole < GridObject
  def initialize(grid, num, location)
    super grid, num, location
    grid.holes[num] = self
  end
end

class Tile < GridObject
  def initialize(grid, num, location, score)
    super grid, num, location
    grid.tiles[num] = self
    @score = score

    def score
      @score
    end
  end
end

class Obstacle < GridObject
  def initialize(grid, num, location)
    super grid, num, location
    grid.obstacles[num] = self
  end
end
