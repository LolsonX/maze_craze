# MazeCraze
# A terminal-based maze generation and solving library in Crystal.
# Supports Unicode rendering, configurable start/end points, and pathfinding via Dijkstra’s algorithm.

require "./cli"
require "./cell_config"
require "./cell"
require "./maze"
require "./maze_generation_renderer"

module MazeCraze
  VERSION = "0.1.0"

  def self.run
    defaults = CLI::Option.new(
      height: 10_u32,
      width: 20_u32,
      method: MazeCraze::Maze::GenerationMethod::DepthFirstSearch,
      animate: false,
      render_to: nil,
      save_to: nil,
      maze: nil,
    )

    options = CLI.parse_options(defaults)
    width, height = options.width, options.height
    maze = options.maze || begin
        new_maze = MazeCraze::Maze.new(options.width, options.height)
        new_maze.configure(
          MazeCraze::CellConfig.new(0_u32, 0_u32),
          MazeCraze::CellConfig.new(width - 1, height - 1)
        )
        new_maze.tap &.generate!(options.method, options.animate)
    end

    maze_renderer = MazeCraze::MazeGenerationRenderer.new(maze)
                                                     .tap { |maze_renderer| maze.renderer = maze_renderer }

    if render_to = options.render_to
      File.open(render_to, "w") { |file| maze_renderer.render(file) }
    else
      maze_renderer.render(STDOUT)
    end

    if save_to = options.save_to
      File.open(save_to, "w") { |file| file.puts(maze.to_json) }
    end
    exit 0

  rescue ex : File::Error
    STDERR.puts "File Error: #{ex.message}"
    exit 1
  end
end

MazeCraze.run
