module Page exposing (Page(..), view)

import Browser exposing (Document)
import Html exposing (Html, a, div, li, nav, text, ul)
import Html.Attributes exposing (class, classList)
import Route exposing (Route)
import Viewer exposing (Viewer)


type Page
    = Other
    | Home
    | Learning


view : Maybe Viewer -> Page -> { title : String, content : Html msg } -> Document msg
view maybeViewer page { title, content } =
    { title = title ++ " - Developer Den"
    , body = viewHeader page :: content :: []
    }


viewHeader : Page -> Html msg
viewHeader page =
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a [ class "navbar-brand", Route.href Route.Home ]
                [ text "Developer Den" ]
            , ul [ class "nav navbar-nav pull-xs-right" ] <|
                navbarLink page Route.Learning [ text "Learning" ]
                    :: []
            ]
        ]


navbarLink : Page -> Route -> List (Html msg) -> Html msg
navbarLink page route linkContent =
    li [ classList [ ( "nav-item", True ), ( "active", True ) ] ]
        [ a [ class "nav-link", Route.href route ] linkContent ]
