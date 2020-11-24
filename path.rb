require "treemap"

def shortestPath(grid, from, to)
  grid.printGrid
  puts "finding path from #{from} to #{to}"
  list = []
  queue = TreeMap.new
  list << from
  queue.put(0, list)
  while !queue.empty?
    path = queue.remove(queue.first_key)
    last = path[path.size - 1]
    if last.equal? to
      # path to destination
      return makePath(path)
    end
    generateNext(grid, to, path, queue, Direction::UP)
    generateNext(grid, to, path, queue, Direction::DOWN)
    generateNext(grid, to, path, queue, Direction::LEFT)
    generateNext(grid, to, path, queue, Direction::RIGHT)
  end
  return nil
end

#try to find the way via this direction
def generateNext(grid, to, path, queue, direction)
  puts "generateNext #{direction}"
  last = path.last
  nextLocation = last.nextLocation(direction)
  if (grid.validMove(last, direction) || nextLocation.equal?(to))
    puts "considering this direction"
    newPath = Array.new(path)
    if !hasLoop(newPath, nextLocation)
      newPath << nextLocation
      cost = newPath.size + nextLocation.distance(to)
      puts "no loop, adding #{nextLocation} at cost #{cost} to path: #{newPath}"
      queue.put(cost, newPath)
    end
  end
end

# check for loops
def hasLoop(path, nextLocation)
  path.each { |l|
    if l.equal? nextLocation
      return true
    end
  }
  return false
end

# make a list of directions from a list of locations
def makePath(list)
  path = []
  last = list.delete_at(0)
  list.each { |loc|
    dir = last.getDirection(loc)
    path << dir
    last = loc
  }
  return path
end
