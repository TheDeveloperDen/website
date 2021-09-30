module Main exposing (main)

import Browser
import Html exposing (Html, pre, text)
import Http exposing (Error)
import Json.Decode as D


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias LearningResourceIndex =
    { name : String
    }


indexDecoder : D.Decoder (List LearningResourceIndex)
indexDecoder =
    D.list (D.field "name" D.string |> D.map LearningResourceIndex)


type alias LearningResources =
    { name : String
    , description : String
    , resources : List LearningResource
    }


type alias LearningResource =
    { name : String
    , url : String
    , price : Maybe Int
    , pros : List String
    , cons : List String
    }


resourcesDecoder : D.Decoder LearningResources
resourcesDecoder =
    D.map3 LearningResources
        (D.field "name" D.string)
        (D.field "description" D.string)
        (D.field "resources" (D.list resourceDecoder))


resourceDecoder : D.Decoder LearningResource
resourceDecoder =
    D.map5 LearningResource
        (D.field "name" D.string)
        (D.field "url" D.string)
        (D.field "price" (D.maybe D.int))
        (D.field "pros" (D.list D.string))
        (D.field "cons" (D.list D.string))


type Model
    = Failure Error
    | Success String
    | Loading


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , Http.get
        { url = "https://developerden.net/learning-resources/"
        , expect = Http.expectJson GotText indexDecoder
        }
    )



-- UPDATE


type Msg
    = GotText (Result Http.Error (List LearningResourceIndex))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        GotText result ->
            case result of
                Ok indices ->
                    ( Success (List.map .name indices |> String.join ", "), Cmd.none )

                Err s ->
                    ( Failure s, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Failure e ->
            text ("I was unable to load your book." ++ Debug.toString e)

        Loading ->
            text "Loading..."

        Success fullText ->
            pre [] [ text fullText ]
