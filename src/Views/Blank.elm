module Views.Blank exposing (..)

import Html exposing (Html)


view : { title : String, content : Html msg }
view =
    { title = ""
    , content = Html.text ""
    }
