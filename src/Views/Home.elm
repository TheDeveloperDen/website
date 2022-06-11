module Views.Home exposing (Model, Msg, init, toSession, view)

import Html exposing (Html, a, button, div, h1, h2, i, text)
import Html.Attributes exposing (class, href)
import Redirects exposing (discordURL, githubURL)
import Session exposing (Session)
import Tailwind as Tw


type alias Model =
    { session : Session
    }


type alias Msg =
    ()


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session }
    , Cmd.none
    )


view : Model -> { title : String, content : Html Msg }
view _ =
    { title = "Home"
    , content =
        div [ Tw.flex, Tw.flex_col, Tw.my_auto, Tw.h_auto, Tw.items_center, Tw.justify_center, Tw.text_white ]
            [ h1 [ Tw.text_center, Tw.text_9xl, class "horta" ] [ text "Developer Den" ]
            , h2 [ Tw.text_center, Tw.font_titillium, Tw.text_2xl, Tw.py_4 ] [ text "A closely-knit community anchored in a common passion for programming." ]
            , div [ Tw.flex, Tw.flex_row, Tw.space_x_6 ]
                [ a [ href discordURL ] [ button (Tw.bg_indigo_400 :: class "hover:bg-indigo-500 hover:text-white hover:translate-y-1" :: buttonStyles) [ i [ Tw.px_1, Tw.pr_2, class "fab fa-discord" ] [], text "Join our Discord" ] ]
                , a [ href githubURL ] [ button (Tw.bg_blue_400 :: class "hover:bg-blue-500 hover:text-white hover:translate-y-1" :: buttonStyles) [ i [ Tw.px_1, Tw.pr_2, class "fab fa-github" ] [], text "View our GitHub" ] ]
                ]
            ]
    }


buttonStyles =
    [ Tw.text_black, Tw.font_semibold, Tw.rounded, Tw.shadow_sm, Tw.py_4, Tw.px_4, Tw.transform, Tw.transition, Tw.duration_300, Tw.ease_in_out ]


toSession =
    .session
