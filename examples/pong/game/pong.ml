open Gamelle
open Geometry

type player = {pos: float; score: int}

type state =
  {player_left: player; player_right: player; ball_speed: v2; ball_pos: p2}

let init =
  { player_left= {pos= 120.; score= 0}
  ; player_right= {pos= 120.; score= 0}
  ; ball_speed= V2.v 1. 0.
  ; ball_pos= P2.v 200. 120. }

let ball_noise = Box2.v (P2.v (-0.01) (-0.01)) (P2.v (-0.02) (-0.02))

let box_game = Box2.v (P2.v 0. 0.) (V2.v 400. 220.)

let court = Box2.v (P2.v 0. 20.) (V2.v 400. 200.)

let player_left_x = Box2.ox court +. 20.

let player_right_x = Box2.w court -. 20.

let player_height = 50.

let player_grip = 0.4

let ball_x_boost = 0.2

let player_speed {ball_speed; _} = 2. *. V2.norm ball_speed

let player_positions x player =
  Segment.v
    (V2.v x (player.pos -. (player_height /. 2.)))
    (V2.v x (player.pos +. (player_height /. 2.)))

let update_player ~x ~player ~delta_y =
  let pos = player.pos +. delta_y in
  let new_player = {player with pos} in
  let start, end_ = Segment.to_tuple (player_positions x new_player) in
  if Box2.mem start court && Box2.mem end_ court then new_player else player

let reflexion ray edge =
  let normal vec = V2.(v (-1. *. y vec) (x vec)) in
  let normal = V2.unit (normal edge) in
  V2.(ray - (2. * (dot ray normal * normal)))

let incr_score player = {player with score= player.score + 1}

let new_point_ball_speed ball_speed =
  let length = V2.((norm init.ball_speed +. norm ball_speed) /. 2.) in
  V2.(-.length * unit ball_speed)

let collision state ~player_left_speed ~player_right_speed new_ball_pos =
  let {player_left; player_right; ball_pos; ball_speed} = state in
  if P2.x ball_pos > 400. then raise Exit ;
  let top, right, bottom, left = Box.sides court in
  let segment_player_left = player_positions player_left_x player_left in
  let segment_player_right = player_positions player_right_x player_right in
  let ball_segment = Segment.v ball_pos new_ball_pos in
  if Segment.intersect ball_segment right then
    let player_left = incr_score player_left in
    let ball_speed = new_point_ball_speed ball_speed in
    let ball_pos = init.ball_pos in
    {state with player_left; ball_pos; ball_speed}
  else if Segment.intersect ball_segment left then
    let player_right = incr_score player_right in
    let ball_speed = new_point_ball_speed ball_speed in
    let ball_pos = init.ball_pos in
    {state with player_right; ball_pos; ball_speed}
  else if Segment.intersect ball_segment segment_player_left then
    let ball_speed =
      V2.(
        reflexion ball_speed (Segment.vector segment_player_left)
        + v ball_x_boost (player_grip *. player_left_speed)
        + Box.random_mem ball_noise )
    in
    {state with ball_speed}
  else if Segment.intersect ball_segment segment_player_right then
    let ball_speed =
      V2.(
        reflexion ball_speed (Segment.vector segment_player_right)
        + v (-.ball_x_boost) (player_grip *. player_right_speed)
        + Box.random_mem ball_noise )
    in
    {state with ball_speed}
  else
    let state =
      [top; bottom]
      |> List.find_map (fun wall ->
             Segment.intersection ball_segment wall
             |> Option.map (fun _ ->
                    let ball_speed =
                      V2.(
                        reflexion ball_speed (Segment.vector wall)
                        + Box.random_mem ball_noise )
                    in
                    {state with ball_speed} ) )
      |> Option.value ~default:{state with ball_pos= new_ball_pos}
    in
    state

let tick state =
  let {ball_pos; ball_speed; _} = state in
  let new_ball_pos = V2.(ball_pos + ball_speed) in
  collision state new_ball_pos

let color = Color.white

let draw_background ~view = fill_rect ~view ~color:Color.black box_game

let draw_court ~view = draw_rect ~view ~color court

let draw_score ~view ~state =
  (* Todo : use font*)
  let { player_left= {score= score_left; _}
      ; player_right= {score= score_right; _}
      ; _ } =
    state
  in
  let y_start = Box2.oy box_game in
  let y_end = Box2.oy court -. 2. in
  for i = 1 to score_left do
    let x = Box2.ox box_game +. float_of_int (i * 4) in
    draw_line ~view ~color (Segment.v (P2.v x y_start) (P2.v x y_end))
  done ;
  for i = 1 to score_right do
    let x = Box2.maxx box_game -. float_of_int (i * 4) in
    draw_line ~view ~color (Segment.v (P2.v x y_start) (P2.v x y_end))
  done

let draw_ball ~view {ball_pos; _} =
  fill_circle ~view ~color (Circle.v ball_pos 4.)

let draw_players ~view {player_left; player_right; _} =
  let player_left = player_positions player_left_x player_left in
  let player_right = player_positions player_right_x player_right in
  draw_line ~view ~color player_left ;
  draw_line ~view ~color player_right

let update ~view event state =
  let player_speed = player_speed state in
  if Event.is_pressed event Escape then raise Exit ;
  let player_left_speed, state =
    if Event.is_pressed event (Char 'w') then
      let delta_y = -.player_speed in
      let player_left =
        update_player ~x:player_left_x ~player:state.player_left ~delta_y
      in
      (delta_y, {state with player_left})
    else if Event.is_pressed event (Char 's') then
      let delta_y = player_speed in
      let player_left =
        update_player ~x:player_left_x ~player:state.player_left ~delta_y
      in
      (delta_y, {state with player_left})
    else (0., state)
  in
  let player_right_speed, state =
    if Event.is_pressed event Arrow_up then
      let delta_y = -.player_speed in
      let player_right =
        update_player ~x:player_right_x ~player:state.player_right ~delta_y
      in
      (delta_y, {state with player_right})
    else if Event.is_pressed event Arrow_down then
      let delta_y = player_speed in
      let player_right =
        update_player ~x:player_right_x ~player:state.player_right ~delta_y
      in
      (delta_y, {state with player_right})
    else (0., state)
  in
  let state = tick ~player_left_speed ~player_right_speed state in
  draw_background ~view ;
  draw_court ~view ;
  draw_score ~view ~state ;
  draw_ball ~view state ;
  draw_players ~view state ;
  state

let () = run init update
