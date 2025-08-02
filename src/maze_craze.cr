# MazeCraze
# A terminal-based maze generation and solving library in Crystal.
# Supports Unicode rendering, configurable start/end points, and pathfinding via Dijkstra’s algorithm.

require "./cell_config"
require "./cell"
require "./maze"
require "./maze_generation_renderer"

module MazeCraze
  VERSION = "0.1.0"

  WIDTH  = 70_u32
  HEIGHT = 19_u32
end

MazeCraze::Maze.new(MazeCraze::WIDTH, MazeCraze::HEIGHT)
  .tap do |maze|
    maze.configure(
      MazeCraze::CellConfig.new(0, 0),
      MazeCraze::CellConfig.new(MazeCraze::WIDTH - 1, MazeCraze::HEIGHT - 1),
      MazeCraze::MazeGenerationRenderer.new(pointerof(maze)),
    ).generate!(MazeCraze::Maze::GenerationMethod::DepthFirstSearch)
    MazeCraze::MazeGenerationRenderer.new(pointerof(maze)).render
  end
