module Views.Home exposing (Model, Msg(..), init, toSession, view)

import Html exposing (Html, div, p, text)
import Html.Attributes exposing (class)
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
            [ p [ Tw.text_center, Tw.text_9xl, class "horta" ] [ text "The Developer Den" ]
            , p [ Tw.text_center, Tw.font_mono, Tw.m_2 ] [ text "The Developer Den is a " ]
            ]
    }


toSession =
    .session
