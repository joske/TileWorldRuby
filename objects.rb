require_relative "path"

module State
  IDLE = 0
  MOVE_TO_TILE = 1
  MOVE_TO_HOLE = 2
end

class GridObject
  def initialize(num, location)
    @num = num
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
    super num, location
    @grid = grid
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
      puts "#{self} our tile is gone"
      @state = State::IDLE
      return
    end
    # try to find a closer tile
    potentialTile = @grid.getClosestTile(@location)
    if !potentialTile.equal?(@tile)
      puts "#{self} tile #{potentialTile} is now closer than #{@tile}"
      @tile = potentialTile
    end
    if @path.empty?
      @path = shortestPath(@grid, self.location, @tile.location)
      puts "#{self} path: #{@path}"
    else
      dir = @path.shift
      nextMove(dir)
    end
  end

  def pickTile
    puts "agent #{@num}: pickTile"
    @hasTile = true
    @grid.removeTile(@tile)
  end

  def moveToHole
    if @location.equal? @hole.location
      # we have arrived
      dumpTile
      return
    end
    # check if our hole is still there
    if !@grid.object(@hole.location).equal?(@hole)
      puts "#{self} our hole is gone"
      @hole = @grid.getClosestHole(@location)
      return
    end
    # try to find a closer hole
    potentialHole = @grid.getClosestHole(@location)
    if !potentialHole.equal?(@hole)
      puts "#{self} tile #{potentialHole} is now closer than #{@hole}"
      @hole = potentialHole
    end
    if @path.empty?
      @path = shortestPath(@grid, self.location, @hole.location)
      puts "#{self} path: #{@path}"
    else
      dir = @path.shift
      nextMove(dir)
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
  def initialize(num, location)
    super num, location
  end
end

class Tile < GridObject
  def initialize(num, location, score)
    super num, location
    @score = score

    def score
      @score
    end
  end
end

class Obstacle < GridObject
  def initialize(num, location)
    super num, location
  end
end
