open Common
module Bitmap = Bitmap
module Font = Font
module Sound = Sound
module Event = Event
include Draw

let clock = Common.clock
let dt = Common.dt

module Ttf = Tsdl_ttf

let global_window = ref None

let window_size () =
  let x, y = Sdl.get_window_size (Option.get !global_window) in
  (float x, float y)

let run fn =
  let& () = Sdl.init Sdl.Init.(video + audio) in
  let _ = Tsdl_image.init Tsdl_image.Init.(jpg + png) in
  let& _ = Tsdl_mixer.Mixer.init Tsdl_mixer.Mixer.Init.(ogg + mp3) in
  let& _ = Ttf.init () in

  let _ok : bool =
    Tsdl.Sdl.set_hint Tsdl.Sdl.Hint.render_scale_quality "nearest"
  in
  let _ok : bool = Tsdl.Sdl.set_hint Tsdl.Sdl.Hint.render_vsync "1" in

  let& () =
    Tsdl_mixer.Mixer.open_audio 44_100 Tsdl_mixer.Mixer.default_format 2 2048
  in

  let& window =
    Sdl.create_window "Test" ~w:640 ~h:480 Sdl.Window.(windowed + resizable)
  in
  global_window := Some window;
  let& render =
    Sdl.create_renderer ~flags:Sdl.Renderer.(accelerated + presentvsync) window
  in
  Common.set_render render;

  let& _ = Sdl.show_cursor false in

  let t0 = Int32.to_float (Sdl.get_ticks ()) /. 1000.0 in
  Common.start_time := t0;
  Common.now := t0;

  let state = ref Event.default in

  let rec loop () : unit =
    let t0 = Int32.to_float (Sdl.get_ticks ()) /. 1000.0 in
    Common.now_prev := !Common.now;
    Common.now := t0;
    let e = Sdl.Event.create () in
    while Sdl.poll_event (Some e) do
      state := Event.update !state e;
      state := Event.update_mouse !state
    done;

    (* Format.printf "playing: %b@." (Tsdl_mixer.Mixer.playing (Some 1)) ; *)
    set_color 0xFF0000000;
    let& () = Sdl.render_clear render in
    fn !state;

    Sdl.render_present render;
    let now = Int32.to_float (Sdl.get_ticks ()) /. 1000.0 in
    let frame_elapsed = now -. t0 in
    let desired_time = 1.0 /. 60.0 in
    let wait_time =
      Int32.of_float (max 0.0 (1000.0 *. (desired_time -. frame_elapsed)))
    in

    Sdl.delay wait_time;
    loop ()
  in
  (try loop () with Exit -> ());

  Tsdl_mixer.Mixer.close_audio ();
  Tsdl_mixer.Mixer.quit ();
  Tsdl_image.quit ();
  Sdl.destroy_renderer render;
  Sdl.destroy_window window