module MazeCraze
  class Cell
    private getter neighbors : Array(Cell)
    getter x : UInt32
    getter y : UInt32

    property? visited : Bool

    def initialize(@x, @y)
      @neighbors = [] of Cell
      @visited = false
    end

    def visit!
      @visited = true
    end

    def unvisit!
      @visited = false
    end

    def ==(other : Cell)
      other.x == x && other.y == y
    end

    def add_neighbor(cell : Cell)
      @neighbors << cell
    end

    def north_wall?
      @neighbors.none? { |neighbour| @y.positive? && neighbour.y == @y - 1 }
    end

    def south_wall?
      @neighbors.none? { |neighbour| neighbour.y == @y + 1 }
    end

    def west_wall?
      @neighbors.none? { |neighbour| @x.positive? && neighbour.x == @x - 1 }
    end

    def east_wall?
      @neighbors.none? { |neighbour| neighbour.x == @x + 1 }
    end

    def any_neighbor?
      !@neighbors.empty?
    end
  end
end
