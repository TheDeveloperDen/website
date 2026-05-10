module Shared exposing
    ( Flags, decoder
    , Model, Msg
    , init, update, subscriptions
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions

-}

import Api
import Effect exposing (Effect)
import Json.Decode
import Route exposing (Route)
import Shared.Model
import Shared.Msg



-- FLAGS


type alias Flags =
    {}


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.succeed {}



-- INIT


type alias Model =
    Shared.Model.Model


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init _ _ =
    ( { learningIndex = Shared.Model.Loading }
    , Api.getLearningResourcesIndex
        { onResponse = Shared.Msg.LearningIndexResponded }
    )



-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        Shared.Msg.LearningIndexResponded (Ok entries) ->
            ( { model | learningIndex = Shared.Model.Success entries }
            , Effect.none
            )

        Shared.Msg.LearningIndexResponded (Err error) ->
            ( { model | learningIndex = Shared.Model.Failure error }
            , Effect.none
            )

        Shared.Msg.RetryLearningIndex ->
            ( { model | learningIndex = Shared.Model.Loading }
            , Api.getLearningResourcesIndex
                { onResponse = Shared.Msg.LearningIndexResponded }
            )

        Shared.Msg.NoOp ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none
