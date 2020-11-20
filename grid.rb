#!/usr/bin/env ruby

require 'gtk3'

ROWS=50
COLS=50
MAG=20

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

module TileWorld 
    
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

        def initialize(grid, num, col, row)
            super grid, num, col, row
            grid.agents[num] = self
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

    class TileWorld < Gtk::Application
        def initialize(grid)
            @grid = grid
            surface = nil
            super 'be.sourcery.tileworld', Gio::ApplicationFlags::FLAGS_NONE
            signal_connect :activate do |application|
                window = Gtk::ApplicationWindow.new(application)
                window.set_title 'TileWorld'
                window.signal_connect "delete-event" do
                    window.destroy
                end
                frame = Gtk::Frame.new
                frame.shadow_type = Gtk::ShadowType::IN
                window.add frame

                view = Gtk::DrawingArea.new
                view.set_size_request COLS*MAG, ROWS*MAG
                frame.add(view)
    
                view.signal_connect "draw" do |_da, cr|
                    cr.set_source(surface, 0, 0)
                    cr.paint
                    false
                end
                view.signal_connect "configure-event" do |da, _ev|
                    surface.destroy if surface
                    surface = window.window.create_similar_surface(Cairo::CONTENT_COLOR,
                                                                da.allocated_width,
                                                                da.allocated_height)
                    # the configure event have been handled, no need for further
                    # processing
                    true
                end
    
                Thread.new {
                    while true
                        @grid.update
                        rect = Gdk::Rectangle.new(0, 0, view.allocation.width, view.allocation.height)
                        window.window.invalidate_rect(rect, false)
                        redraw(view, surface, @grid.objects)
                        sleep(0.5)
                    end
                }    
                window.show_all     
            end             
        end

        def redraw(view, surface, objects)            
            cr = Cairo::Context.new(surface)
            cr.set_source_rgb(1, 1, 1)
            cr.paint
            cr.set_line_width(2)
            for r in 1..ROWS
                puts
                for c in 1..COLS
                    cr.set_source_rgb(0, 0, 0)
                    o = objects[[c,r]]
                    if o != nil
                        x = c * MAG
                        y = r * MAG
                        if o.instance_of? Agent
                            print 'A'
                            drawAgent(view, cr, o, x, y)
                        elsif o.instance_of? Hole
                            print 'H'
                            cr.arc(x + MAG / 2, y + MAG / 2, MAG / 2, 0, 2 * Math::PI)
                            cr.fill
                        elsif o.instance_of? Tile
                            print 'T'
                            drawTile view, cr, o, x, y
                        elsif o.instance_of? Obstacle
                            print '#'
                            cr.rectangle(x, y, MAG, MAG)
                            cr.fill();
                        end
                    else
                        print '.'
                    end
                    cr.stroke
                end
            end
            puts
        end
        
        def drawAgent(view, cr, a, x, y)     
            r, b, g = getColor(a.num)       
            cr.set_source_rgb(r, g, b)
            cr.rectangle(x, y, MAG, MAG)
            if a.hasTile()
                cr.new_sub_path
                cr.arc(x + MAG / 2, y + MAG / 2, MAG / 2, 0, 2 * Math::PI)
                cr.new_sub_path
                draw_text(cr, x + MAG / 4, y, a.tiles.score.to_s);
            end
        end

        def drawTile(view, cr, tile, x, y)     
            cr.arc(x + MAG / 2, y + MAG / 2, MAG / 2, 0, 2 * Math::PI)
            cr.new_sub_path
            draw_text(cr, x + MAG / 4, y, tile.score.to_s)
        end

        def draw_text(cr, x, y, text)
            font = Pango::FontDescription.new

            font.set_family("Monospace")
            font.set_weight(Pango::WEIGHT_BOLD)
            layout = cr.create_pango_layout
            layout.set_text(text)
            layout.set_font_description(font)
            cr.move_to(x, y);
            cr.show_pango_layout(layout)
        end

        def getColor(num)
            if num == 0
                return 0, 0, 255
            elsif num == 1
                return 255, 0, 0
            elsif num == 2
                return 0, 255, 0
            elsif num == 3
                return 128, 128, 0
            elsif num == 4
                return 0, 128, 128
            elsif num == 5
                return 128, 0, 128
            end
        end
    end

end

grid = TileWorld::Grid.new(2, 5, 5, 5)
app = TileWorld::TileWorld.new(grid)
app.run