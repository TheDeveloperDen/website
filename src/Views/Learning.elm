module Views.Learning exposing (Model, Msg(..), init, toSession, update, view)

import AssocSet as Set exposing (Set)
import Dict exposing (Dict)
import Html exposing (Html, a, button, div, h2, li, p, table, td, text, th, tr, ul)
import Html.Attributes exposing (href)
import Html.Events as Event
import Http
import LearningResource exposing (LearningResource, LearningResourceIndex, LearningResources)
import Session exposing (Session)
import Tailwind
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
        [ Event.onClick (Toggle resources), Tailwind.bg_blue_500, Tailwind.text_white ]
        [ h2 [ Tailwind.font_bold ] [ text resources.name ]
        , p [] [ text resources.description ]
        ]


resourceToTableEntry : LearningResource -> Html Msg
resourceToTableEntry res =
    tr [ Tailwind.whitespace_nowrap ]
        [ td [] [ a [ href res.url ] [ text res.name ] ]
        , td [] [ text (Maybe.map String.fromInt res.price |> Maybe.withDefault "Free") ]
        , td []
            [ ul [] (List.map (text >> List.singleton >> li []) res.pros) ]
        , td []
            [ ul [] (List.map (text >> List.singleton >> li []) res.cons)
            ]
        ]


resourcesToTable : LearningResources -> Html Msg
resourcesToTable resources =
    table [ Tailwind.table_auto, Tailwind.border_separate, Tailwind.divide_y, Tailwind.divide_gray_300 ]
        (tr [ Tailwind.px_6, Tailwind.py_2, Tailwind.text_xs, Tailwind.text_gray_500 ]
            [ th [] [ text "Resource" ]
            , th [] [ text "Price" ]
            , th [] [ text "Pros" ]
            , th [] [ text "Cons" ]
            ]
            :: List.map resourceToTableEntry resources.resources
        )


showResource : LearningResources -> Bool -> Html Msg
showResource resource addTable =
    div [ Tailwind.w_full, Tailwind.border_b, Tailwind.border_gray_200, Tailwind.shadow ]
        (resourcesToButton resource
            :: (if addTable then
                    [ resourcesToTable resource ]

                else
                    []
               )
        )


view : Model -> { title : String, content : Html Msg }
view { session, loadedTopics, openTopics } =
    { title = "Learning"
    , content =
        div [ Tailwind.container, Tailwind.flex, Tailwind.justify_center, Tailwind.mx_auto ]
            [ Dict.values loadedTopics
                |> List.map (\topic -> showResource topic (Set.member topic openTopics))
                |> div [ Tailwind.flex, Tailwind.flex_col ]
            ]
    }


setToggle : Set a -> a -> Set a
setToggle set elem =
    if Set.member elem set then
        Set.remove elem set

    else
        Set.insert elem set


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadedResources (Ok resources) ->
            ( { model | loadedTopics = resources |> List.map (\a -> ( a.name, a )) |> Dict.fromList }, Cmd.none )

        LoadedResources (Err _) ->
            ( model, Cmd.none )

        Toggle res ->
            ( { model | openTopics = setToggle model.openTopics res }, Cmd.none )


toSession =
    .session
