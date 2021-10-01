module Views.Learning exposing (LearningResource, LearningResources, Model, Msg(..), init, toSession, view)

import Html exposing (Html)
import Http
import Json.Decode as D
import Session exposing (Session)


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


resourcesDecoder : D.Decoder LearningResources
resourcesDecoder =
    D.map3 LearningResources
        (D.field "name" D.string)
        (D.field "description" D.string)
        (D.field "resources" (D.list resourceDecoder))


type alias LearningResource =
    { name : String
    , url : String
    , price : Maybe Int
    , pros : List String
    , cons : List String
    }


resourceDecoder : D.Decoder LearningResource
resourceDecoder =
    D.map5 LearningResource
        (D.field "name" D.string)
        (D.field "url" D.string)
        (D.field "price" (D.maybe D.int))
        (D.field "pros" (D.list D.string))
        (D.field "cons" (D.list D.string))


type alias Model =
    { session : Session
    , topic : String
    }


type Msg
    = Show LearningResources
    | Hide LearningResources
    | Indexed (Result Http.Error (List LearningResourceIndex))
    | Loaded (Result Http.Error LearningResources)


baseUrl =
    "https://developerden.net/learning-resources/"


getIndexes : Cmd Msg
getIndexes =
    Http.get
        { url = baseUrl
        , expect = Http.expectJson Indexed indexDecoder
        }


init : Session -> String -> ( Model, Cmd Msg )
init session url =
    ( Model session url, getIndexes )


view : Model -> { title : String, content : Html Msg }
view =
    Debug.todo "View Learning"


toSession =
    .session
