module Page exposing (Page(..), view)

import Browser exposing (Document)
import Html exposing (Attribute, Html, a, div, nav, text)
import Route exposing (Route)
import Tailwind as Tw


type Page
    = Home
    | Rules


view : Page -> { title : String, content : Html msg } -> Document msg
view page { title, content } =
    { title = title ++ " - Developer Den"
    , body = [ background [ navbar page, content ] ]
    }


background : List (Html msg) -> Html msg
background =
    div [ Tw.bg_gradient_to_r, Tw.from_blue_700, Tw.to_pink_700, Tw.min_h_screen, Tw.bg_fixed, Tw.flex, Tw.flex_col ]


navbar : Page -> Html msg
navbar page =
    nav [ Tw.font_titillium, Tw.absolute, Tw.left_5, Tw.top_5, Tw.bg_gray_200, Tw.space_x_5, Tw.p_3, Tw.rounded_2xl, Tw.shadow_md, Tw.px_5 ]
        [ navbarLink page Route.Home "home"
        , navbarLink page Route.Rules "rules"
        ]


navbarLink : Page -> Route -> String -> Html msg
navbarLink page route name =
    if isActive page route then
        a (Route.href route :: selected) [ text name ]

    else
        a (Route.href route :: deselected) [ text name ]


selected : List ( Attribute msg )
selected =
    [ Tw.font_bold, Tw.rounded_2xl, Tw.px_3, Tw.py_1, Tw.bg_gradient_to_r, Tw.from_blue_700, Tw.to_pink_700, Tw.text_gray_50 ]


deselected : List ( Attribute msg )
deselected =
    [ Tw.hover__bg_gray_300, Tw.rounded_2xl, Tw.px_3, Tw.py_1, Tw.ease_in_out, Tw.duration_300 ]


isActive : Page -> Route -> Bool
isActive page route =
    case ( page, route ) of
        ( Home, Route.Home ) ->
            True

        ( Rules, Route.Rules ) ->
            True

        _ ->
            False
