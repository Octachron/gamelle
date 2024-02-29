open Cmdliner

let file_contents full_name =
  let h = open_in_bin full_name in
  let r = In_channel.input_all h in
  close_in h;
  r

let re_target = Str.regexp_string "<%GAME%>"

let game_template script =
  {|<canvas id=target tabindex=1></canvas>|}
  ^ {|<script type="text/javascript">|} ^ script ^ {|</script>|}

let inline_js_in_html html js =
  let html = file_contents html in
  let js = game_template (file_contents js) in
  let html = Str.substitute_first re_target (fun _ -> js) html in
  print_endline html

let normalize_name name =
  String.map
    (function ('a' .. 'z' | 'A' .. 'Z' | '0' .. '9') as c -> c | _ -> '_')
    name

let extension_loader ~basename ~ext =
  match (basename, ext) with
  | _, "Ttf" -> Some "Gamelle.Font.load"
  | _, ("Png" | "Jpeg" | "Jpg") -> Some "Gamelle.Bitmap.load"
  | "assets", _ | "dune", "No_ext" -> None
  | _ -> Some "Fun.id"

let output_file (full_name, basename, loader) =
  if Sys.is_regular_file full_name then (
    Format.printf "  (** Generated from %s *)@." basename;
    Format.printf "  let %s = %s %S@." basename loader (file_contents full_name))

let split_file_ext filename =
  let name = normalize_name @@ Filename.remove_extension filename in
  let raw_ext = Filename.extension filename in
  let ext =
    String.capitalize_ascii
    @@
    if raw_ext = "" then "No_ext"
    else if String.starts_with ~prefix:"." raw_ext then
      String.(sub raw_ext 1 (length raw_ext - 1))
    else raw_ext
  in
  (name, ext)

module StringMap = Map.Make (struct
  type t = string

  let compare = compare
end)

let gen_ml files cwd =
  let files =
    Array.fold_left
      (fun map sysname ->
        let basename, ext = split_file_ext sysname in
        match extension_loader ~basename ~ext with
        | Some loader ->
            StringMap.add_to_list ext
              (Filename.concat cwd sysname, basename, loader)
              map
        | None -> map)
      StringMap.empty files
  in
  StringMap.iter
    (fun ext files ->
      Format.printf "module %s = struct@." ext;
      List.iter output_file files;
      Format.printf "end@.include %s@." ext)
    files

let list_files k =
  let cwd = Sys.getcwd () in
  Format.printf "(* %S *)@." cwd;
  k (Sys.readdir cwd) cwd

let cmd_assets =
  let doc = "Bundle game assets" in
  let info = Cmd.info "assets" ~doc in
  let run () = list_files gen_ml in
  Cmd.v info Term.(const run $ const ())

let html_template =
  let env =
    let doc = "Template HTML" in
    Cmd.Env.info "" ~doc
  in
  Arg.(
    required & opt (some file) None & info [ "template" ] ~docv:"TEMPLATE" ~env)

let js_script =
  let env =
    let doc = "Js script" in
    Cmd.Env.info "" ~doc
  in
  Arg.(required & opt (some file) None & info [ "script" ] ~docv:"SCRIPT" ~env)

let cmd_html =
  let doc = "Release HTML game" in
  let info = Cmd.info "html" ~doc in
  let run html js = inline_js_in_html html js in
  Cmd.v info Term.(const run $ html_template $ js_script)

let cmd =
  let doc = "Gamelle" in
  let version = "0.1" in
  let info = Cmd.info "gamelle" ~version ~doc in
  Cmd.group info [ cmd_assets; cmd_html ]

let () = exit (Cmd.eval cmd)