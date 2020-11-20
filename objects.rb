module State
  IDLE = 0
  MOVE_TO_TILE = 1
  MOVE_TO_HOLE = 2
end

class GridObject
  def initialize(grid, num, col, row)
    @num = num
    @row = row
    @col = col
    @grid = grid
    grid.objects[[col, row]] = self
  end

  def num
    @num
  end

  def col
    @col
  end

  def row
    @row
  end
end

class Agent < GridObject
  def initialize(grid, num, col, row)
    super grid, num, col, row
    grid.agents[num] = self
    @state = State::IDLE
    @tile = nil
    @hole = nil
    @score = 0
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
    @col, @row = @grid.nextLocation(@col, @row, dir)
  end

  def location()
    return @col, @row
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
    puts "#{self} finding tile"
    @tile = @grid.getClosestTile(@col, @row)
    puts "#{self} found tile #{@tile}"
    @state = State::MOVE_TO_TILE
  end

  def moveToTile
    if @tile.col == @col && @tile.row == row
      # we have arrived
      pickTile
      @hole = @grid.getClosestHole(@col, @row)
      @state = State::MOVE_TO_HOLE
    end
    best_dir = findBestMove(@tile.col, @tile.row)
    if best_dir != 0
      nextMove(best_dir)
    end
  end

  def pickTile
    @hasTile = true
    @grid.removeTile(@tile)
  end

  def findBestMove(col, row)
    r = rand(1..10)
    if (r > 3)
      # 20 % chance to pick a random move to get out of local minima
      return rand(1..4)
    end
    min_dist = 100000
    best_dir = 0
    for dir in 1..4
      newCol, newRow = @grid.nextLocation(@col, @row, dir)
      if newCol == col && newRow == row
        #arrived
        return dir
      end
      if @grid.allowedLocation(newCol, newRow)
        dist = @grid.distance(col, row, newCol, newRow)
        if dist < min_dist
          min_dist = dist
          best_dir = dir
        end
      end
    end
    return best_dir
  end

  def moveToHole
    if @hole.col == @col && @hole.row == row
      # we have arrived
      dumpTile
      return
    end
    best_dir = findBestMove(@hole.col, @hole.row)
    if best_dir != 0
      nextMove(best_dir)
    end
  end

  def dumpTile
    @tile = nil
    @hasTile = false
    @grid.removeHole(@hole)
    @hole = nil
    @state = State::IDLE
  end

  def to_s
    return "agent #{@num} at col=#{@col}, row=#{@row} in state #{@state}"
  end
end

class Hole < GridObject
  def initialize(grid, num, col, row)
    super grid, num, col, row
    grid.holes[num] = self
  end
end

class Tile < GridObject
  def initialize(grid, num, col, row, score)
    super grid, num, col, row
    grid.tiles[num] = self
    @score = score

    def score
      @score
    end
  end
end

class Obstacle < GridObject
  def initialize(grid, num, col, row)
    super grid, num, col, row
    grid.obstacles[num] = self
  end
end
