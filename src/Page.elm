module Page exposing (Page(..), view)

import Browser exposing (Document)
import Html exposing (Html, a, div, li, nav, text, ul)
import Html.Attributes exposing (class, classList)
import Route exposing (Route)


type Page
    = Other
    | Home
    | Learning


view : Page -> { title : String, content : Html msg } -> Document msg
view page { title, content } =
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
                navbarLink page (Route.Learning "Haskell") [ text "Haskell" ]
                    :: []
            ]
        ]


navbarLink : Page -> Route -> List (Html msg) -> Html msg
navbarLink page route linkContent =
    li [ classList [ ( "nav-item", True ), ( "active", True ) ] ]
        [ a [ class "nav-link", Route.href route ] linkContent ]
