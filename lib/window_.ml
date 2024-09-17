open Gamelle_common
open Geometry
module W = Gamelle_backend.Window

let size ~io = W.size ~io

let set_size ~io s =
  let w = s |> Size.width |> int_of_float
  and h = s |> Size.height |> int_of_float in
  io.window_size := (w, h)

let box ~io = Box.v Vec.zero (size ~io)
let show_cursor = W.show_cursor
