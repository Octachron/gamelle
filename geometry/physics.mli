open Gg

type t
type kind = Movable | Immovable

val make :
  ?mass:float ->
  ?inertia:float ->
  ?restitution:float ->
  ?kind:kind ->
  Shape.t ->
  t

val center : t -> P2.t
val add_velocity : V2.t -> t -> t
val add_rot_velocity : float -> t -> t
val update : dt:float -> t -> t
val fix_collisions : t list -> t list

module Make (S : Draw.S) : sig
  val draw : io:S.io -> t -> unit
end