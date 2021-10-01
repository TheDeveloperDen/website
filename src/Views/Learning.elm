module Views.Learning exposing (Model, Msg(..), init, toSession, update, view)

import Html exposing (Html, text)
import Http
import LearningResource exposing (LearningResourceIndex, LearningResources)
import Session exposing (Session)
import Task


type alias Model =
    { session : Session
    , indexes : List LearningResourceIndex
    , topic : Status LearningResources
    }


type Status a
    = Loading
    | Loaded a
    | LoadingSlowly
    | Failed


type Msg
    = Show LearningResources
    | Hide LearningResources
    | Indexed (Result Http.Error (List LearningResourceIndex))
    | LoadedResources (Result Http.Error LearningResources)


init : Session -> Maybe String -> ( Model, Cmd Msg )
init session url =
    ( Model session [] Loading, LearningResource.getIndexes |> Task.attempt Indexed )


view : Model -> { title : String, content : Html Msg }
view model =
    case model.topic of
        Loading ->
            { title = "Loading", content = text (Debug.toString model.indexes) }

        LoadingSlowly ->
            { title = "Loading", content = text "Slowly..." }

        Failed ->
            { title = "Failed", content = text "Failed to load" }

        Loaded a ->
            { title = "Loaded", content = text a.name }



--{ title = Debug.toString model.topic, content = model.topic |> Debug.toString |> text }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Indexed (Ok resources) ->
            ( { model | indexes = resources }, Cmd.none )

        Indexed (Err e) ->
            ( model, Cmd.none )

        _ ->
            ( Debug.log "model" model, Cmd.map (always (Debug.log "msg" msg)) Cmd.none )


toSession =
    .session
