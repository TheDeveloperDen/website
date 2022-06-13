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
            , div [ Tw.absolute, Tw.bottom_5, Tw.right_5, Tw.flex, Tw.flex_row, Tw.space_x_1, Tw.rounded_xl, Tw.py_1, Tw.px_1, Tw.bg_gray_300, Tw.shadow_md ]
                  [ a [ href discordURL ] [ button (class "hover:bg-indigo-500 hover:text-white" :: buttonStyles) [ i [ Tw.px_1, class "fab fa-discord" ] [] ] ]
                  , a [ href githubURL ] [ button (class "hover:bg-gray-900 hover:text-white" :: buttonStyles) [ i [ Tw.px_1, class "fab fa-github" ] [] ] ]
                  ]
            ]
    }


buttonStyles =
    [ Tw.font_titillium, Tw.rounded_2xl, Tw.text_black, Tw.font_semibold, Tw.py_3, Tw.px_3, Tw.transform, Tw.transition, Tw.duration_300, Tw.ease_in_out ]


toSession =
    .session
