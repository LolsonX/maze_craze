module MazeCraze
  class MazeGenerationRenderer
    FRAMES_PER_SECOND = 15
    FRAME_DURATION    = 1.second / FRAMES_PER_SECOND

    CELL_GLYPH = [
      ["█", "█", "█"],
      ["█", "█", "█"],
      ["█", "█", "█"],
    ]

    CELL_WIDTH  = CELL_GLYPH.size
    CELL_HEIGHT = CELL_GLYPH.first.size

    SPECIAL_SYMBOLS = {
      start:   "\u{17D9}",
      end:     "\u{0F12}",
      current: "╳",
      solid:   "█",
      default: " ",
    }

    def initialize(@maze_ptr : Pointer(Maze))
      # Clear the screen
      print "\e[2J"
    end

    def render(io : IO = STDOUT)
      io.print "#{self}"
      sleep(FRAME_DURATION)
    end

    def to_s(io : IO) : String
      io.write(to_s)
    end

    def to_s : String
      String.build(maze.width * CELL_WIDTH * maze.height * CELL_HEIGHT * 2) do |buffer|
        buffer << "#{map_maze}\n"
      end
    end

    def map_maze
      maze.height.times.map do |y|
        maze.width.times.map do |x|
          cell_glyph = glyph(x, y)
          map_glyph(x, y, cell_glyph)
        end.join
      end.join
    end

    def map_glyph(x : UInt32, y : UInt32, glyph : Array(Array(String)))
      CELL_HEIGHT.times.map do |y_offset|
        CELL_WIDTH.times.map do |x_offset|
          row = y * CELL_HEIGHT + y_offset + 1
          col = x * CELL_WIDTH + x_offset + 1
          "\e[#{row};#{col}H#{glyph[y_offset][x_offset]}"
        end.join
      end.join
    end

    private def maze
      @maze_ptr.value
    end

    private def glyph(x : UInt32, y : UInt32)
      cell_box(x, y).map_with_index do |row, row_index|
        row.map_with_index do |cell, col_index|
          current_symbol = SPECIAL_SYMBOLS[symbol(x, row_index, y, col_index)]
          cell ? CELL_GLYPH[row_index][col_index] : current_symbol * CELL_GLYPH[row_index][col_index].size
        end
      end
    end

    def symbol(x, x_offset, y, y_offset)
      if x_offset == 1 && y_offset == 1
        return cell_type(x, y)
      end
      :default
    end

    def cell_box(x : UInt32, y : UInt32)
      [
        [true, north_wall_of?(x, y), true],
        [west_wall_of?(x, y), false, east_wall_of?(x, y)],
        [true, south_wall_of?(x, y), true],
      ]
    end

    def north_wall_of?(x : UInt32, y : UInt32)
      maze.north_wall_of?(x, y)
    end

    def south_wall_of?(x : UInt32, y : UInt32)
      maze.south_wall_of?(x, y)
    end

    def west_wall_of?(x : UInt32, y : UInt32)
      maze.west_wall_of?(x, y)
    end

    def east_wall_of?(x : UInt32, y : UInt32)
      maze.east_wall_of?(x, y)
    end

    def cell_type(x, y)
      maze.cell_type(x, y)
    end

    def visited?(x : UInt32, y : UInt32)
      maze.cell_visited?(x, y)
    end
  end
end
