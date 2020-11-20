require 'gtk3'
require './objects.rb'
    
class Grid
    
    def initialize(numAgents, numHoles, numTiles, numObstacles)
        @numAgents = numAgents
        @numHoles = numHoles
        @numTiles = numTiles
        
        @agents = []
        @holes = []
        @tiles = []
        @obstacles = []
        @objects = Hash.new # store as hash, with key the array [col, row] -- Ruby has no 2d array
        # create agents
        for a in 0..(numAgents - 1)
            col = rand(1..COLS)
            row = rand(1..ROWS)
            agent = Agent.new(self, a, col, row)
            
        end
        for a in 0..(numHoles - 1)
            col = rand(1..COLS)
            row = rand(1..ROWS)
            while @objects[[col,row]] != nil
                col = rand(1..COLS)
                row = rand(1..ROWS)
            end
            hole = Hole.new(self, a, col, row)
        end
        for a in 0..(numTiles - 1)
            col = rand(1..COLS)
            row = rand(1..ROWS)
            score = rand(1..5)
            while @objects[[col,row]] != nil
                col = rand(1..COLS)
                row = rand(1..ROWS)
            end
            tile = Tile.new(self, a, col, row, score)
        end
        for a in 0..(numObstacles - 1)
            col = rand(1..COLS)
            row = rand(1..ROWS)
            while @objects[[col,row]] != nil
                col = rand(1..COLS)
                row = rand(1..ROWS)
            end
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

    def update
        @agents.each() { |a|
            puts a
            origRow, origCol = a.location
            a.nextMove
            puts a
            newRow, newCol = a.location
            @objects[[origCol,origRow]] = nil
            @objects[[newCol,newRow]] = a
        }
    end
end

