module Views.Home exposing (Model, Msg(..), init, toSession, view)

import Html exposing (Html, text)
import Session exposing (Session)


type alias Model =
    { session : Session
    }


type Msg
    = GotSession Session
    | PausedSlowLoadThreshold


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session }
    , Cmd.none
    )


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Home", content = text "" }


toSession =
    .session
