include Gg
module Segment = Segment
module Circle = Circle
module Box = Box

module Make (Draw : Draw.S) = struct
  module Shape = struct
    include Shape
    include Shape.Make (Draw)
  end

  module Physics = struct
    include Physics
    include Physics.Make (Draw)
  end
end
