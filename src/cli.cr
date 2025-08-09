require "option_parser"

module CLI
  GENERATION_METHODS = {
    "dfs" => MazeCraze::Maze::GenerationMethod::DepthFirstSearch,
  }

  struct Option
    property height : UInt32
    property width : UInt32
    property method : MazeCraze::Maze::GenerationMethod
    property animate : Bool
    property render_to : String?
    property save_to : String?
    property maze : MazeCraze::Maze?

    def initialize(@height, @width, @method, @animate, @render_to, @save_to, @maze); end
  end

  def self.parse_options(options : Option)
    OptionParser.parse do |parser|
      parser.banner = "Usage: maze_craze [options]"

      parser.on("-w WIDTH", "--width=WIDTH", "Width of the maze") do |user_width|
        options.width = user_width.to_u32
      end

      parser.on("-h HEIGHT", "--height=HEIGHT", "Height of the maze") do |user_height|
        options.height = user_height.to_u32
      end

      parser.on("-m METHOD", "--method=METHOD", "Generation method (e.g., dfs)") do |generation_method|
        options.method = if (method = GENERATION_METHODS[generation_method.downcase]?)
          method
        else
          STDERR.puts("Unknown method: #{generation_method}")
          exit 1
        end
      end

      parser.on("-a", "--animate", "Animate generation") do
        options.animate = true
      end

      parser.on("-H", "--help", "Show this help") do
        puts parser
        exit
      end

      parser.on("-r", "--render-to=FILE_PATH", "Redirect final render to given file") do |file_path|
        options.render_to = file_path
      end

      parser.on("-s", "--save-to=FILE_PATH", "Save final maze to given file") do |file_path|
        options.save_to = file_path
      end

      parser.on("-l", "--load=FILE_PATH", "Load maze from given file") do |file_path|
        options.maze = MazeCraze::Maze.from_json(File.read(file_path))
      end
    end
    options
  end
end
