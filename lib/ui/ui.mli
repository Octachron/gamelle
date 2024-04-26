open Gamelle_backend
open Draw_geometry

type t
type cap = t * string

module Style : module type of Style

val window : ?debug:bool -> io:io -> point -> (t -> 'a) -> 'a * box
val button : cap -> ?id:int -> ?init:bool -> ?style:Style.t -> string -> bool
val checkbox : cap -> ?id:int -> ?init:bool -> ?style:Style.t -> string -> bool
val label : cap -> ?style:Style.t -> string -> unit
val text_area : cap -> ?style:Style.t -> ?width:float -> string -> unit

val slider :
  ?id:int ->
  ?init:float ->
  ?style:Style.t ->
  ?width:float ->
  cap ->
  min:float ->
  max:float ->
  float

val vertical : cap -> ?style:Style.t -> (unit -> 'a) -> 'a
val horizontal : cap -> ?style:Style.t -> (unit -> 'a) -> 'a
val vscroll : cap -> ?style:Style.t -> height:float -> (unit -> 'a) -> 'a

val radio :
  cap ->
  ?id:int ->
  ?init:'a option ->
  ?style:Style.t ->
  ('a * string) list ->
  'a option

val text_input :
  cap -> ?id:int -> ?init:string -> ?style:Style.t -> float -> string

val nest_loc : cap -> (unit -> 'a) -> 'a

module Customize : sig
  module Button = Button
  module Checkbox = Checkbox
  module Horizontal = Horizontal
  module Label = Label
  module Radio = Radio
  module Slider = Slider
  module Text_area = Text_area
  module Text_input = Text_input
  module Vertical = Vertical
  module Widget_builder = Widget_builder
end
