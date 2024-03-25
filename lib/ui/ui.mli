open Gamelle_backend
open Geometry

type t
type cap = t * string

type ('state, 'params, 'r) elt =
  cap ->
  ?id:int ->
  ?size:(ts:(string -> size2) -> 'params -> size2) ->
  ?render:(io:io -> 'params -> 'state -> box2 -> unit) ->
  'params ->
  'r

type 'params inert_elt =
  cap ->
  ?id:int ->
  ?size:(ts:(string -> size2) -> 'params -> size2) ->
  ?render:(io:io -> 'params -> box2 -> unit) ->
  'params ->
  unit

type ('state, 'params, 'r) node =
  cap ->
  ?id:int ->
  ?size:(ts:(string -> size2) -> children_size:size2 -> 'params -> size2) ->
  ?render:(io:io -> 'params -> 'state -> box2 -> unit) ->
  'params ->
  'r

type vscroll_state = {
  size : size2;
  offset : float;
  grasped : bool;
  real_height : float;
}

type slider_state = { v : float; grasped : bool }
type slider_params = { w : float; min : float; max : float }
type 'a vscroll_params = { height : float; f : unit -> 'a }

val ui : ?debug:bool -> io:io -> p2 -> (t -> 'a) -> 'a * box2
val button : (bool, string, bool) elt
val checkbox : (bool, string, bool) elt
val label : cap -> ?weight:float -> string -> unit
val slider : (slider_state, slider_params, float) elt
val vertical : cap -> ?weight:float -> (unit -> 'a) -> 'a
val horizontal : cap -> ?weight:float -> (unit -> 'a) -> 'a
val vscroll : (vscroll_state, 'a vscroll_params, 'a) node