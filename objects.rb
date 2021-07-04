require_relative 'astar'

module State
  IDLE = 0
  MOVE_TO_TILE = 1
  MOVE_TO_HOLE = 2
end

class GridObject
  attr_reader :num
  attr_accessor :location

  def initialize(num, location)
    @num = num
    @location = location
  end

  def col
    @location.col
  end

  def row
    @location.row
  end

  def equal?(other)
    @num == other.num && @location == other.location && self.class == other.class
  end

  def to_s
    "#{self.class.name} #{@num} at #{location}"
  end
end

class Agent < GridObject
  attr_accessor :score, :tile, :has_tile

  def initialize(grid, num, location)
    super num, location
    @grid = grid
    @state = State::IDLE
    @tile = nil
    @hole = nil
    @score = 0
    @has_tile = false
  end

  # updates the location of this agent
  def nextMove(location)
    puts "move #{location}"
    @location = location
  end

  def update
    if @state == State::IDLE
      idle
    elsif @state == State::MOVE_TO_TILE
      move_to_tile
    else
      move_to_hole
    end
  end

  def idle
    @tile = nil
    @hole = nil
    @has_tile = false
    puts "#{self} finding tile"
    @tile = @grid.getClosestTile(@location)
    puts "#{self} found tile #{@tile}"
    @state = State::MOVE_TO_TILE
  end

  def move_to_tile
    if @tile.location.equal? location
      # we have arrived
      pick_tile
      return
    end
    # try to find a closer tile
    @tile = @grid.getClosestTile(@location)
    path = astar(@grid, @location, @tile.location)
    puts "#{self} path: #{@path}"
    unless path.empty?
      next_loc = path.shift
      nextMove(next_loc) if @grid.freeLocation(next_loc) || next_loc.equal?(@tile.location)
    end
  end

  def pick_tile
    puts "agent #{@num}: pick_tile"
    @has_tile = true
    @grid.removeTile(@tile)
    @hole = @grid.getClosestHole(@location)
    @state = State::MOVE_TO_HOLE
  end

  def move_to_hole
    if @location.equal? @hole.location
      # we have arrived
      dump_tile
      return
    end
    @hole = @grid.getClosestHole(@location)
    path = astar(@grid, location, @hole.location)
    puts "#{self} path: #{@path}"

    unless path.empty?
      next_loc = path.shift
      nextMove(next_loc) if @grid.freeLocation(next_loc) || next_loc.equal?(@hole.location)
    end
  end

  def dump_tile
    puts "agent #{@num}: dump_tile"
    @score += @tile.score
    @tile = nil
    @has_tile = false
    @grid.removeHole(@hole)
    @hole = nil
    @tile = @grid.getClosestTile(@location)
    puts "#{self} found tile #{@tile}"
    @state = State::MOVE_TO_TILE
  end

  def to_s
    "Agent #{@num} at #{@location} in state #{@state} has_tile=#{@has_tile} tile=#{@tile} hole=#{@hole}"
  end
end

class Hole < GridObject
end

class Tile < GridObject
  attr_accessor :score

  def initialize(num, location, score)
    super num, location
    @score = score
  end
end

class Obstacle < GridObject
end
