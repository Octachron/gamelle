open Brr
open Common
module Geometry = Gamelle_geometry
open Geometry
module Color = Color
module Bitmap = Bitmap
module Font = Font
module Sound = Sound
module Transform = Gamelle_common.Transform
include Draw
include Gamelle_geometry.Make (Draw)

(* type ctx = C.t *)

module Io = Gamelle_common.Io

type io = Draw.io

let prev_now = ref 0.0
let now = ref 0.0
let clock = Io.clock
let dt = Io.dt
(* let clock () = !now *)
(* let dt () = !now -. !prev_now *)

module Window = struct
  let size () =
    let canvas = Option.get !global_canvas in
    let w = Canvas.w canvas in
    let h = Canvas.h canvas in
    Size2.v (float w) (float h)

  let set_size (w, h) =
    let canvas = Option.get !global_canvas in
    Canvas.set_w canvas w;
    Canvas.set_h canvas h

  let box () = Box2.v V2.zero (size ())
end

module View = struct
  include Gamelle_common.Io

  type 'a scene = io:io -> 'a

  let drawing_box box io =
    let tr =
      Geometry.(
        V2.(Box.(o (centered box (Window.box ()))) - io.centering_translation))
    in
    let io = { io with centering_translation = tr } in
    translated tr io
end

let run state update =
  let canvas =
    match Document.find_el_by_id G.document (Jstr.of_string "target") with
    | None -> failwith "missing 'target' canvas"
    | Some elt ->
        Event.attach ~target:(El.as_target elt);
        Canvas.of_el elt
  in

  let clock = ref 0 in

  global_canvas := Some canvas;

  Canvas.set_w canvas 640;
  Canvas.set_h canvas 480;

  let ctx = C.get_context canvas in
  global_ctx := Some ctx;

  let rec animate state =
    let _ = G.request_animation_frame (loop state) in
    ()
  and loop state elapsed =
    prev_now := !now;
    now := elapsed /. 1000.0;
    Event.new_frame ();
    let io =
      {
        (Io.make ~font:Font.default ()) with
        event = { !Event.current with clock = !clock };
      }
    in
    incr clock;
    fill_rect ~io ~color:Color.black (Window.box ());
    let state = update ~io state in
    Event.current := Gamelle_common.Event.reset_wheel !Event.current;
    animate state
  in
  animate state

module Event = Gamelle_common.Io

