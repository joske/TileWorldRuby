module Direction
    UP = 1
    DOWN = 2
    LEFT = 3
    RIGHT = 4
end

def nextLocation(oldCol, oldRow, dir)
    if (dir == Direction::UP)
        return oldCol, oldRow - 1
    elsif (dir == Direction::DOWN)
        return oldCol, oldRow + 1
    elsif (dir == Direction::LEFT)
        return oldCol - 1, oldRow
    else
        return oldCol + 1, oldRow
    end        
end

def validMove(col, row, dir)
    if (dir == Direction::UP)
        return row > 1 && @grid.objects[[col, row - 1]] == nil
    elsif (dir == Direction::DOWN)
        return row < ROWS && @grid.objects[[col, row + 1]] == nil
    elsif (dir == Direction::LEFT)
        return col > 1 && @grid.objects[[col - 1, row]] == nil
    else
        return col < COLS && @grid.objects[[col + 1, row]] == nil
    end        

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
end
        
class Agent < GridObject
    @tile = nil
    @score = 0

    def initialize(grid, num, col, row)
        super grid, num, col, row
        grid.agents[num] = self
    end
    def set_score score
        @score = score
    end

    def score
        @score
    end

    # updates the location of this agent
    def nextMove()
        dir = rand(1..4) #random walk for now
        while !validMove(@col, @row, dir)
            dir = rand(1..4) #random walk for now
        end
        puts "move #{dir}"
        @col, @row = nextLocation(@col, @row, dir)
    end
    
    def location() 
        return @col, @row
    end

    def hasTile
        return @tile != nil
    end

    def set_tile(tile)
        @tile = tile
    end

    def tile
        @tile
    end

    def to_s
        return "agent #{@num} at col=#{@col}, row=#{@row}"
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
