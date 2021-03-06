open Tester
open! Tc
open Runtime

let run () =
  describe "pathFromInputVars" (fun () ->
      let noRequest = StrDict.empty in
      let noURL = StrDict.fromList [("request", Types.DObj StrDict.empty)] in
      let generate url =
        StrDict.fromList
          [("request", Types.DObj (StrDict.fromList [("url", Types.DStr url)]))]
      in
      test "returns None if no request object" (fun () ->
          expect (pathFromInputVars noRequest) |> toEqual None) ;
      test "returns None if no url object" (fun () ->
          expect (pathFromInputVars noURL) |> toEqual None) ;
      test "returns None if no url is parseable - numbers" (fun () ->
          expect (pathFromInputVars (generate "123456")) |> toEqual None) ;
      test "returns None if no url is parseable - no slashes" (fun () ->
          expect (pathFromInputVars (generate "localhost")) |> toEqual None) ;
      test "returns None if no url is parseable - no scheme" (fun () ->
          expect (pathFromInputVars (generate "//foobar.builwithdark.com"))
          |> toEqual None) ;
      test "returns path with no query string" (fun () ->
          expect
            (pathFromInputVars
               (generate "https://foobar.builwithdark.com/hello"))
          |> toEqual (Some "/hello")) ;
      test "returns path with query string" (fun () ->
          expect
            (pathFromInputVars
               (generate
                  "https://foobar.builwithdark.com/hello?foo=bar&baz=quux"))
          |> toEqual (Some "/hello?foo=bar&baz=quux"))) ;
  ()
