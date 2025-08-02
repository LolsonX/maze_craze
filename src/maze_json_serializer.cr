require "json"

module MazeCraze
  module MazeJsonSerializer
    def as_json
      {
        "width"      => width,
        "height"     => height,
        "start_cell" => [start_cell.x, start_cell.y],
        "end_cell"   => [end_cell.x, end_cell.y],
        "cells"      => serialized_cells,
      }
    end

    def to_json
      as_json.to_json
    end

    private def serialized_cells
      @maze.map do |row|
        row.map do |cell|
          {
            "x"         => cell.x,
            "y"         => cell.y,
            "neighbors" => cell.serialized_neighbors,
          }
        end
      end
    end

    def self.from_json(json)
      data = JSON.parse(json)

      width = data["width"].as_i.to_u32
      height = data["height"].as_i.to_u32

      MazeCraze::Maze.new(width, height).tap do |maze|
        maze.configure(
          MazeCraze::CellConfig.new(data["start_cell"][0].as_i.to_u32, data["start_cell"][1].as_i.to_u32),
          MazeCraze::CellConfig.new(data["end_cell"][0].as_i.to_u32, data["end_cell"][1].as_i.to_u32),
        )

        # Build a lookup for cells
        cell_map = {} of Tuple(UInt32, UInt32) => Cell
        width.times do |x|
          height.times do |y|
            cell = maze.cell_at(x, y)
            cell_map[{x, y}] = cell
          end
        end

        data["cells"].as_a.each do |row|
          row.as_a.each do |cell_data|
            x = cell_data["x"].as_i.to_u32
            y = cell_data["y"].as_i.to_u32
            cell = cell_map[{x, y}]
            cell_data["neighbors"].as_a.each do |neighbor_data|
              nx = neighbor_data["x"].as_i.to_u32
              ny = neighbor_data["y"].as_i.to_u32
              neighbor = cell_map[{nx, ny}]
              cell.add_neighbor(neighbor)
            end
          end
        end
        maze.generated!
      end
    end
  end
end
