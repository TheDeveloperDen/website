module Views.Home exposing (..)

import Html exposing (Html)
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
    Debug.todo "View Home"


toSession =
    .session
