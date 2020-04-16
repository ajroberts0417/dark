open Core_kernel
open Lib
open Types.RuntimeT
module RT = Runtime

let fns =
  [ { prefix_names = ["Option::map"]
    ; infix_names = []
    ; parameters = [par "option" TOption; func ["val"]]
    ; return_type = TOption
    ; description =
        "If `option` is `Just value`, returns `Just (f value)` (the lambda `f` is applied to `value` and the result is wrapped in `Just`).
        If `result` is `Nothing`, returns `Nothing`."
    ; func =
        InProcess
          (function
          | state, [DOption o; DBlock b] ->
            ( match o with
            | OptJust dv ->
                let result = Ast.execute_dblock ~state b [dv] in
                DOption (OptJust result)
            | OptNothing ->
                DOption OptNothing )
          | args ->
              fail args)
    ; preview_safety = Safe
    ; deprecated = true }
  ; { prefix_names = ["Option::map_v1"]
    ; infix_names = []
    ; parameters = [par "option" TOption; func ["val"]]
    ; return_type = TOption
    ; description =
        "If `option` is `Just value`, returns `Just (f value)` (the lambda `f` is applied to `value` and the result is wrapped in `Just`).
        If `result` is `Nothing`, returns `Nothing`."
    ; func =
        InProcess
          (function
          | state, [DOption o; DBlock b] ->
            ( match o with
            | OptJust dv ->
                let result = Ast.execute_dblock ~state b [dv] in
                Dval.to_opt_just result
            | OptNothing ->
                DOption OptNothing )
          | args ->
              fail args)
    ; preview_safety = Safe
    ; deprecated = false }
  ; { prefix_names = ["Option::map2"]
    ; infix_names = []
    ; parameters =
        [par "option1" TOption; par "option2" TOption; func ["v1"; "v2"]]
    ; return_type = TOption
    ; description =
        "If both arguments are `Just` (`option1` is `Just v1` and `option2` is `Just v2`), returns `Just (f v1 v2)` --
        the lambda `f` is applied to `v1` and `v2`, and the result is wrapped in `Just`.
        If `option1` or `option2` are `Nothing`, returns `Nothing`."
    ; func =
        InProcess
          (function
          | state, [DOption o1; DOption o2; DBlock b] ->
            ( match (o1, o2) with
            | OptNothing, _ | _, OptNothing ->
                DOption OptNothing
            | OptJust dv1, OptJust dv2 ->
                let result = Ast.execute_dblock ~state b [dv1; dv2] in
                Dval.to_opt_just result )
          | args ->
              fail args)
    ; preview_safety = Safe
    ; deprecated = false }
  ; { prefix_names = ["Option::andThen"]
    ; infix_names = []
    ; parameters = [par "option" TOption; func ["val"]]
    ; return_type = TOption
    ; description =
        "If `option` is `Just value`, returns `f value` (the lambda `f` is applied to `value` and must return `Just newValue` or `Nothing`). If `option` is `Nothing`, returns `Nothing`."
    ; func =
        InProcess
          (function
          | state, [DOption o; DBlock b] ->
            ( match o with
            | OptJust dv ->
                let result = Ast.execute_dblock ~state b [dv] in
                ( match result with
                | DOption result ->
                    DOption result
                | other ->
                    RT.error
                      ~actual:other
                      ~expected:"an option"
                      "Expected `f` to return an option" )
            | OptNothing ->
                DOption OptNothing )
          | args ->
              fail args)
    ; preview_safety = Safe
    ; deprecated = false }
  ; { prefix_names = ["Option::withDefault"]
    ; infix_names = []
    ; parameters = [par "option" TOption; par "default" TAny]
    ; return_type = TAny
    ; description =
        "If `option` is `Just value`, returns `value`. Returns `default` otherwise."
    ; func =
        InProcess
          (function
          | _, [DOption o; default] ->
            (match o with OptJust dv -> dv | OptNothing -> default)
          | args ->
              fail args)
    ; preview_safety = Safe
    ; deprecated = false } ]
