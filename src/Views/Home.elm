module Views.Home exposing (Model, Msg(..), init, toSession, view)

import Html exposing (Html, a, button, div, h1, h2, i, p, text)
import Html.Attributes exposing (class, href)
import Redirects exposing (discordURL, githubURL)
import Session exposing (Session)
import Tailwind as Tw


type alias Model =
    { session : Session
    }


type Msg
    = GotSession Session


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session }
    , Cmd.none
    )


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Home"
    , content =
        div [ Tw.flex, Tw.flex_col, Tw.my_auto, Tw.h_auto, Tw.items_center, Tw.justify_center ]
            [ h1 [ Tw.text_center, Tw.text_9xl, class "horta" ] [ text "The Developer Den" ]
            , h2 [ Tw.text_center, Tw.font_mono, Tw.py_4 ] [ text "An inclusive community of programmers who want to learn more and create cool stuff together." ]
            , div []
                [ a [ href discordURL, Tw.px_5 ] [ button [ Tw.bg_indigo_400, Tw.font_semibold, Tw.rounded, Tw.shadow_sm, Tw.py_4, Tw.px_4 ] [ i [ Tw.px_2, class "fab fa-discord" ] [], text "Join our Discord" ] ]
                , a [ href githubURL, Tw.px_5 ] [ button [ Tw.bg_blue_400, Tw.font_semibold, Tw.rounded, Tw.shadow_sm, Tw.py_4, Tw.px_4 ] [ i [ Tw.px_2, class "fab fa-github" ] [], text "View our GitHub" ] ]
                ]
            ]
    }


toSession =
    .session
