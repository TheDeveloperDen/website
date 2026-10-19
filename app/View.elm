module View exposing (View, fromStyled, map)

{-| View module for elm-pages with frozen view support.

@docs View, fromStyled, map

-}

import Html exposing (Html)
import Html.Styled


{-| -}
type alias View msg =
    { title : String
    , body : List (Html msg)
    }


{-| Build a view from `elm-css` styled HTML.
-}
fromStyled : String -> List (Html.Styled.Html msg) -> View msg
fromStyled title body =
    { title = title
    , body = List.map Html.Styled.toUnstyled body
    }


{-| -}
map : (msg1 -> msg2) -> View msg1 -> View msg2
map fn doc =
    { title = doc.title
    , body = List.map (Html.map fn) doc.body
    }
