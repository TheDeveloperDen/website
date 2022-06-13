module Page exposing (Page(..), view)

import Browser exposing (Document)
import Html exposing (Html, a, button, div, img, nav, span, text)
import Html.Attributes exposing (alt, class, href, src)
import Html.Attributes.Aria exposing (ariaControls, ariaExpanded)
import Redirects exposing (discordURL, githubURL)
import Route exposing (Route)
import Tailwind as Tw
import Tailwind.LG as TwLG
import Tailwind.SM as TwSM
import Viewer exposing (Viewer)


type Page
    = Other
    | Home
    | Rules


view : Maybe Viewer -> { title : String, content : Html msg } -> Document msg
view _ { title, content } =
    { title = title ++ " - Developer Den"
    , body = [ background [ content ] ]
    }


background : List (Html msg) -> Html msg
background =
    div [ Tw.bg_gradient_to_r, Tw.from_blue_700, Tw.to_pink_700, Tw.min_h_screen, Tw.bg_fixed, Tw.flex, Tw.flex_col ]
