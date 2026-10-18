port module Ports exposing (setTheme)

{-| Ports to the browser. Handlers live in `index.ts`.

@docs setTheme

-}


{-| Apply a theme (`"dark"` or `"light"`) to the page and remember it for next visit.
-}
port setTheme : String -> Cmd msg
