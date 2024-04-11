type io

val run : 'state -> (io:io -> 'state -> 'state) -> unit

open Gamelle_geometry
module Geometry : module type of Gamelle_geometry
module Color : module type of Color

module Bitmap : sig
  type t

  val load : string -> t
  val sub : t -> int -> int -> int -> int -> t
end

module Font : sig
  type t

  val default : t
  val default_size : int
  val load : string -> t
  val draw : color:Color.t -> t -> int -> string -> Bitmap.t
end

module Sound : sig
  type sound

  val load : string -> sound
  val play : io:io -> sound -> unit

  type music

  val load_music : string -> music
  val play_music : io:io -> music -> unit
end

module Transform : sig
  type t

  val default : t
  val translate : V2.t -> t -> t
  val scale : float -> t -> t
  val rotate : float -> t -> t
  val project : t -> P2.t -> P2.t
end

module View : sig
  type 'a scene = io:io -> 'a

  val ( & ) : unit scene -> unit scene -> unit scene
  val drawing_box : Box.t -> io -> io
  val translate : V2.t -> 'a scene -> 'a scene
  val scale : float -> 'a scene -> 'a scene
  val rotate : float -> 'a scene -> 'a scene
  val clip : box2 -> 'a scene -> 'a scene
  val unclip : 'a scene -> 'a scene
  val clip_events : bool -> 'a scene -> 'a scene
  val translated : V2.t -> io -> io
  val scaled : float -> io -> io
  val rotated : float -> io -> io
  val clipped : box2 -> io -> io
  val unclipped : io -> io
  val clipped_events : bool -> io -> io
end

val clock : unit -> float
val dt : unit -> float
val draw : io:io -> Bitmap.t -> p2 -> unit
val draw_line : io:io -> color:Color.t -> Segment.t -> unit
val draw_rect : io:io -> color:Color.t -> box2 -> unit
val fill_rect : io:io -> color:Color.t -> box2 -> unit
val draw_poly : io:io -> color:Color.t -> p2 list -> unit
val fill_poly : io:io -> color:Color.t -> p2 list -> unit
val draw_circle : io:io -> color:Color.t -> Circle.t -> unit
val fill_circle : io:io -> color:Color.t -> Circle.t -> unit
val show_cursor : bool -> unit

val draw_string :
  io:io -> color:Color.t -> ?font:Font.t -> ?size:int -> string -> p2 -> unit

val text_size : io:io -> ?font:Font.t -> ?size:int -> string -> size2

module Event : sig
  val mouse_pos : io:io -> p2
  val wheel_delta : io:io -> float

  type key =
    [ `quit
    | `escape
    | `control_left
    | `control_right
    | `arrow_left
    | `arrow_right
    | `arrow_up
    | `arrow_down
    | `char of char
    | `click_left
    | `click_right
    | `wheel
    | `unknown_key ]

  val is_pressed : io:io -> key -> bool
  val is_up : io:io -> key -> bool
  val is_down : io:io -> key -> bool
end

module Window : sig
  val set_size : int * int -> unit
  val size : unit -> size2
  val box : unit -> box2
end

(* *)
