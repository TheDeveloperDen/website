module Views.Learning exposing (Model, Msg(..), init, toSession, update, view)

import AssocSet as Set exposing (Set)
import Dict exposing (Dict)
import Html exposing (Html, a, button, div, h2, p, table, td, text, th, tr)
import Html.Attributes exposing (href)
import Html.Events as Event
import Http
import LearningResource exposing (LearningResourceIndex, LearningResources)
import Session exposing (Session)
import Task


type alias Model =
    { session : Session
    , loadedTopics : Dict String LearningResources
    , openTopics : Set LearningResources
    }


type Msg
    = Toggle LearningResources
    | LoadedResources (Result Http.Error (List LearningResources))


init : Session -> ( Model, Cmd Msg )
init session =
    ( Model session Dict.empty Set.empty
    , LearningResource.getIndexes
        |> Task.map (List.filter (.name >> (/=) "resource.schema.json"))
        |> Task.andThen (List.map LearningResource.getResources >> Task.sequence)
        |> Task.attempt LoadedResources
    )


resourcesToButton : LearningResources -> Html Msg
resourcesToButton resources =
    button
        [ Event.onClick (Toggle resources) ]
        [ h2 [] [ text resources.name ]
        , p [] [ text resources.description ]
        ]


resourcesToTable : LearningResources -> Html Msg
resourcesToTable resources =
    table []
        [ tr []
            [ th [] [ text "Resource" ]
            , th [] [ text "Price" ]
            , th [] [ text "Pros" ]
            , th [] [ text "Cons" ]
            ]
        , tr
            []
            [ td [] [ a [ href "learn" ] [ text "learn you a haskell" ] ]
            ]
        ]


view : Model -> { title : String, content : Html Msg }
view { session, loadedTopics, openTopics } =
    { title = "Learning"
    , content =
        div []
            [ Dict.values loadedTopics
                |> List.map resourcesToButton
                |> div []
            , openTopics
                |> Set.map resourcesToTable
                |> Set.toList
                |> div []
            ]
    }


setToggle : Set a -> a -> Set a
setToggle set elem =
    if Set.member elem set then
        Set.remove elem set

    else
        Set.insert elem set



--{ title = Debug.toString model.topic, content = model.topic |> Debug.toString |> text }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    Debug.log "response" <|
        case msg of
            LoadedResources (Ok resources) ->
                ( { model | loadedTopics = resources |> List.map (\a -> ( a.name, a )) |> Dict.fromList }, Cmd.none )

            LoadedResources (Err e) ->
                ( model, Cmd.none )

            Toggle res ->
                ( { model | openTopics = setToggle model.openTopics res }, Cmd.none )


toSession =
    .session
