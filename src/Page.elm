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
    | Learning
    | About


view : Maybe Viewer -> Page -> { title : String, content : Html msg } -> Document msg
view maybeViewer page { title, content } =
    { title = title ++ " - Developer Den"
    , body = [ background [ viewHeader page, content ] ]
    }


background : List (Html msg) -> Html msg
background =
    div [ Tw.bg_gradient_to_r, Tw.from_blue_700, Tw.to_pink_700, Tw.h_screen, Tw.bg_fixed, Tw.flex, Tw.flex_col ]


viewHeader : Page -> Html msg
viewHeader page =
    nav [ Tw.bg_gray_800 ]
        [ div [ Tw.max_w_7xl, Tw.mx_auto, Tw.px_2, TwSM.px_6, TwLG.px_8 ]
            [ div [ Tw.relative, Tw.flex, Tw.items_center, Tw.justify_between, Tw.h_16 ]
                [ div [ Tw.absolute, Tw.inset_y_0, Tw.left_0, Tw.flex, Tw.items_center, TwSM.hidden ]
                    [ button [ Tw.inline_flex, Tw.items_center, Tw.justify_center, Tw.p_2, Tw.rounded_md, Tw.text_gray_400, ariaControls "mobile", ariaExpanded "false" ]
                        [ span [ Tw.sr_only ] [ text "Open main menu" ]
                        ]
                    ]
                , div [ Tw.flex_1, Tw.flex, Tw.items_center, Tw.justify_center, TwSM.items_stretch, TwSM.justify_start ]
                    [ div [ Tw.flex_shrink_0, Tw.flex, Tw.items_center ]
                        [ img [ Tw.hidden, TwLG.block, Tw.h_8, Tw.w_auto, src "devden_text_only_wide.png", alt "Developer Den Logo" ] []
                        ]
                    , div [ Tw.hidden, TwSM.block, TwSM.ml_6 ]
                        [ div [ Tw.flex, Tw.space_x_4 ]
                            [ navbarLink page Route.Home [ text "Home" ]
                            , navbarLink page Route.Learning [ text "Learning" ]
                            , navbarLink page Route.About [ text "About Us" ]
                            , a (href discordURL :: navbarLinkStyle) [ text "Discord" ]
                            , a (href githubURL :: navbarLinkStyle) [ text "GitHub" ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


navbarLink : Page -> Route -> List (Html msg) -> Html msg
navbarLink page route linkContent =
    if isActive page route then
        a [ Tw.bg_gray_900, Tw.text_white, Tw.px_3, Tw.py_2, Tw.rounded_md, Tw.text_sm, Tw.font_medium, Route.href route ] linkContent

    else
        a (Route.href route :: navbarLinkStyle) linkContent


navbarLinkStyle =
    [ Tw.text_gray_300, Tw.px_3, Tw.py_2, Tw.rounded_md, Tw.text_sm, Tw.font_medium, Tw.transform, Tw.transition, Tw.duration_300, Tw.ease_in_out, class "hover:bg-gray-700 hover:text-white" ]


isActive : Page -> Route -> Bool
isActive page route =
    case ( page, route ) of
        ( Home, Route.Home ) ->
            True

        ( Learning, Route.Learning ) ->
            True

        ( About, Route.About ) ->
            True

        _ ->
            False
