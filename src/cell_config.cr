module MazeCraze
  class CellConfig
    getter x : UInt32
    getter y : UInt32
    getter glyph : String

    def initialize(@x : UInt32, @y : UInt32, @glyph : String); end
  end
end
