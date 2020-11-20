
module Direction
    UP = 1
    DOWN = 2
    LEFT = 3
    RIGHT = 4
end

class Grid
    
    def initialize(numAgents, numHoles, numTiles, numObstacles)
        @numAgents = numAgents
        @numHoles = numHoles
        @numTiles = numTiles
        
        @agents = []
        @holes = Hash.new
        @tiles = Hash.new
        @obstacles = []
        @objects = Hash.new # store as hash, with key the array [col, row] -- Ruby has no 2d array
        # create agents
        for a in 0..(numAgents - 1)
            col, row = randomFreeLocation
            agent = Agent.new(self, a, col, row)
            
        end
        for a in 0..(numHoles - 1)
            createHole(a)
        end
        for a in 0..(numTiles - 1)
            createTile(a)
        end
        for a in 0..(numObstacles - 1)
            col, row = randomFreeLocation
            obst = Obstacle.new(self, a, col, row)
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
        col, row = randomFreeLocation
        tile = Tile.new(self, a, col, row, score)
        @tiles[a] = tile
    end

    def createHole(a)
        col, row = randomFreeLocation
        hole = Hole.new(self, a, col, row)
        @holes[a] = hole
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
    
    def allowedLocation(col, row)
        @objects[[col, row]] == nil
    end
    
    def validMove(col, row, dir)
        if (dir == Direction::UP)
            return row > 1 && allowedLocation(col, row - 1)
        elsif (dir == Direction::DOWN)
            return row < ROWS && allowedLocation(col, row + 1)
        elsif (dir == Direction::LEFT)
            return col > 1 && allowedLocation(col - 1, row)
        else
            return col < COLS && allowedLocation(col + 1, row)
        end        
    
    end 
    
    def randomFreeLocation
        col = rand(0..COLS - 1)
        row = rand(0..ROWS - 1)
        while @objects[[col,row]] != nil
            col = rand(0..COLS - 1)
            row = rand(0..ROWS - 1)
        end
        return col, row
    end

    def distance(col1, row1, col2, row2)
        return (col1 - col2).abs + (row1 - row2).abs
    end

    def getClosestTile(col, row)
        closest = 1000000
        best = nil
        @tiles.each_value {|t|
            dist = distance(col, row, t.col, t.row)
            if dist < closest
                closest = dist
                best = t
            end 
        }
        return best
    end

    def getClosestHole(col, row)
        closest = 1000000
        best = nil
        @holes.each_value {|h|
            dist = distance(col, row, h.col, h.row)
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
            origRow, origCol = a.location
            a.update
            puts a
            newRow, newCol = a.location
            @objects[[origCol,origRow]] = nil
            @objects[[newCol,newRow]] = a
        }
    end
end

