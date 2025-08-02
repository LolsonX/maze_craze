# MazeCraze
# A terminal-based maze generation and solving library in Crystal.
# Supports Unicode rendering, configurable start/end points, and pathfinding via Dijkstra’s algorithm.

require "option_parser"
require "./cell_config"
require "./cell"
require "./maze"
require "./maze_generation_renderer"

module MazeCraze
  VERSION = "0.1.0"
end

# Defaults
width = 20_u32
height = 10_u32
method = MazeCraze::Maze::GenerationMethod::DepthFirstSearch
animate = false
render_io = STDOUT
save_to = nil

OptionParser.parse do |parser|
  parser.banner = "Usage: maze_craze [options]"

  parser.on("-w WIDTH", "--width=WIDTH", "Width of the maze") do |user_width|
    width = user_width.to_u32
  end

  parser.on("-h HEIGHT", "--height=HEIGHT", "Height of the maze") do |user_height|
    height = user_height.to_u32
  end

  parser.on("-m METHOD", "--method=METHOD", "Generation method (e.g., dfs)") do |generation_method|
    method = case generation_method.downcase
             when "dfs"
               MazeCraze::Maze::GenerationMethod::DepthFirstSearch
             else
               STDERR.puts "Unknown method: #{generation_method}"
               exit 1
             end
  end

  parser.on("-a", "--animate", "Animate generation") do
    animate = true
  end

  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end

  parser.on("-r", "--render-to=FILE_PATH", "Redirect final render to given file") do |file_path|
    render_io = File.open(file_path, "w")
  end

  parser.on("-s", "--save-to=FILE_PATH", "Save final maze to given file") do |file_path|
    save_to = File.open(file_path, "w")
  end
end

maze = MazeCraze::Maze.new(width, height)
maze_renderer = MazeCraze::MazeGenerationRenderer.new(pointerof(maze))
maze.configure(
  MazeCraze::CellConfig.new(0_u32, 0_u32),
  MazeCraze::CellConfig.new(width - 1, height - 1),
  maze_renderer
)
maze.generate!(method, animate)
maze_renderer.render(render_io)
render_io.close if render_io != STDOUT
if target = save_to
  target.puts(maze.to_json)
  target.close
end
