module MazeCraze
  class Maze
    # ──────────────── Constants & Types ────────────────
    OFFSETS = [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

    class NotConfiguredError < Exception; end

    class AlreadyGeneratedError < Exception; end

    enum GenerationMethod
      DepthFirstSearch
    end

    # ──────────────── Instance Variables ────────────────
    @rand : Random
    @start_cell : Cell?
    @end_cell : Cell?
    @stack : Array(Cell) = [] of Cell

    # - Public API  -
    getter width : UInt32
    getter height : UInt32

    # - Private API -
    private getter maze : Array(Array(Cell)) = [] of Array(Cell)
    private getter renderer : MazeGenerationRenderer?
    private getter? generated : Bool = false
    private getter? configured : Bool = false

    # - Lifecycle -
    def initialize(@width : UInt32, @height : UInt32, @rand : Random = Random::DEFAULT)
      @maze = (0_u32...width).map { |x| (0_u32...height).map { |y| Cell.new(x, y) } }
    end

    def configure(start_cell : CellConfig, end_cell : CellConfig, renderer : MazeGenerationRenderer? = nil)
      tap do
        @renderer = renderer
        @start_cell = cell_at(start_cell.x, start_cell.y)
        @end_cell = cell_at(end_cell.x, end_cell.y)
        @configured = true
      end
    end

    def generate!(generation_method : GenerationMethod, animate = false) : Maze
      tap do
        raise NotConfiguredError.new unless configured?
        raise AlreadyGeneratedError.new if generated?

        case generation_method
        when GenerationMethod::DepthFirstSearch
          generate_randomized_dfs(start_cell, end_cell, animate)
        else
          raise "Unsupported method: #{generation_method}"
        end

        unvist_all_cells
        @generated = true
      end
    end

    # - Cell Information Accessors -
    def north_wall_of?(x : UInt32, y : UInt32) : Bool
      cell_at(x, y).north_wall?
    end

    def south_wall_of?(x : UInt32, y : UInt32) : Bool
      cell_at(x, y).south_wall?
    end

    def west_wall_of?(x : UInt32, y : UInt32) : Bool
      cell_at(x, y).west_wall?
    end

    def east_wall_of?(x : UInt32, y : UInt32) : Bool
      cell_at(x, y).east_wall?
    end

    def cell_visited?(x : UInt32, y : UInt32) : Bool
      cell_at(x, y).visited?
    end

    def cell_type(x : UInt32, y : UInt32) : Symbol
      cell = cell_at(x, y)
      return :start if cell == start_cell
      return :end if cell == end_cell
      return :current if cell == @stack.last?
      return :solid unless cell.any_neighbor?
      :default
    end

    # - Private Helpers -
    private def cell_at(x : UInt32, y : UInt32) : Cell
      raise ArgumentError.new("Out of bounds: #{x}, #{y}") if x >= width || y >= height
      maze[x][y]
    end

    private def start_cell : Cell
      @start_cell || raise "Start Cell not set"
    end

    private def end_cell : Cell
      @end_cell || raise "End Cell not set"
    end

    private def unvist_all_cells
      @maze.each(&.each(&.unvisit!))
    end

    private def render
      renderer.try &.render
    end

    private def carve(from : Cell, to : Cell)
      from.add_neighbor(to)
      to.add_neighbor(from)
    end

    # - DFS Maze Generation -
    private def generate_randomized_dfs(start_cell : Cell, end_cell : Cell, animate : Bool)
      start_cell.visit!
      @stack = [start_cell]

      until @stack.empty?
        current_cell = @stack.pop
        neighbors = get_possible_neighbors(current_cell)
        unless neighbors.empty?
          next_cell = neighbors.sample
          visit_neighbor(current_cell, next_cell)
        end
        render if animate
      end

      raise "Maze generation incomplete — end not reached" unless end_cell.visited?
    end

    private def visit_neighbor(current_cell : Cell, next_cell : Cell)
      @stack << current_cell
      next_cell.visit!
      carve(current_cell, next_cell)
      @stack << next_cell
    end

    private def get_possible_neighbors(cell : Cell) : Array(Cell)
      OFFSETS.compact_map do |(x_offset, y_offset)|
        next if (x_offset < 0 && cell.x < x_offset.abs) || (y_offset < 0 && cell.y < y_offset.abs)

        x_neighbour, y_neighbour = cell.x + x_offset, cell.y + y_offset
        next if x_neighbour >= width || y_neighbour >= height

        neighbor = cell_at(x_neighbour, y_neighbour)
        neighbor unless neighbor.visited?
      end
    end
  end
end
