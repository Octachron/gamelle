open Gamelle_common
open Geometry
open Jsoo
module C = Brr_canvas.C2d

type io = Jsoo.io

let set_color ~io c =
  let r, g, b, a = Color.to_srgbi c in
  let color =
    C.color (Jstr.of_string (Printf.sprintf "rgba(%i,%i,%i,%f)" r g b a))
  in
  C.set_fill_style io.backend.ctx color;
  C.set_stroke_style io.backend.ctx color

let transform ~io =
  let { view; _ } = io in
  C.reset_transform io.backend.ctx;
  let dx, dy = Vec.to_tuple view.translate in
  C.translate io.backend.ctx ~x:dx ~y:dy;
  C.rotate io.backend.ctx view.rotate;
  C.scale io.backend.ctx ~sx:view.scale ~sy:view.scale

let draw ~io bmp p =
  transform ~io;
  let x, y = Vec.to_tuple p in
  let ctx = io.backend.ctx in
  Clip.draw_clip ~io ctx (fun () -> Bitmap.draw ~io ~ctx bmp ~x ~y)

let fill_rect ~io ~color rect =
  transform ~io;
  let x, y = Vec.to_tuple (Box.o rect) in
  let w, h = Vec.to_tuple (Box.size rect) in
  set_color ~io color;
  let ctx = io.backend.ctx in
  Clip.draw_clip ~io ctx (fun () -> C.fill_rect ctx ~x ~y ~w ~h)

let draw_rect ~io ~color rect =
  transform ~io;
  let x, y = Vec.to_tuple (Box.o rect) in
  let w, h = Vec.to_tuple (Box.size rect) in
  set_color ~io color;
  let ctx = io.backend.ctx in
  Clip.draw_clip ~io ctx (fun () -> C.stroke_rect ctx ~x ~y ~w ~h)

let draw_line ~io ~color segment =
  let p0, p1 = Segment.to_tuple segment in
  transform ~io;
  let x0, y0 = Vec.to_tuple p0 in
  let x1, y1 = Vec.to_tuple p1 in
  set_color ~io color;
  let ctx = io.backend.ctx in
  Clip.draw_clip ~io ctx (fun () ->
      let path = C.Path.create () in
      C.Path.move_to path ~x:x0 ~y:y0;
      C.Path.line_to path ~x:x1 ~y:y1;
      C.stroke io.backend.ctx path)

let path_poly pts =
  let path = C.Path.create () in
  List.iter
    (fun pt ->
      let x, y = Vec.to_tuple pt in
      C.Path.line_to path ~x ~y)
    (Polygon.to_list pts);
  C.Path.close path;
  path

let draw_poly ~io ~color poly =
  transform ~io;
  set_color ~io color;
  let ctx = io.backend.ctx in
  Clip.draw_clip ~io ctx (fun () ->
      let path = path_poly poly in
      C.stroke ctx path)

let fill_poly ~io ~color poly =
  transform ~io;
  set_color ~io color;
  let ctx = io.backend.ctx in
  Clip.draw_clip ~io ctx (fun () ->
      let path = path_poly poly in
      C.fill ctx path)

let tau = 8.0 *. atan 1.0

let draw_circle ~io ~color circle =
  let center = Circle.center circle in
  let radius = Circle.radius circle in
  transform ~io;
  set_color ~io color;
  let x, y = Vec.to_tuple center in
  let path = C.Path.create () in
  let ctx = io.backend.ctx in
  Clip.draw_clip ~io ctx (fun () ->
      C.Path.arc path ~cx:x ~cy:y ~r:radius ~start:0.0 ~stop:tau;
      C.stroke ctx path)

let fill_circle ~io ~color circle =
  let center = Circle.center circle in
  let radius = Circle.radius circle in
  transform ~io;
  set_color ~io color;
  let x, y = Vec.to_tuple center in
  let path = C.Path.create () in
  let ctx = io.backend.ctx in
  Clip.draw_clip ~io ctx (fun () ->
      C.Path.arc path ~cx:x ~cy:y ~r:radius ~start:0.0 ~stop:tau;
      C.fill ctx path)

let show_cursor ~io status =
  let canvas = io.backend.canvas in
  let el = Canvas.to_el canvas in
  if status then Brr.El.remove_inline_style Brr.El.Style.cursor el
  else Brr.El.set_inline_style Brr.El.Style.cursor (Jstr.of_string "none") el
