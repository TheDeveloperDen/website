module LearningResource exposing (LearningResource, LearningResourceIndex, LearningResources, baseUrl, getIndexes, getResources, indexDecoder, resourceDecoder, resourcesDecoder)

import Http
import HttpUtil exposing (HttpTask, getTask)
import Json.Decode as D
import Task exposing (Task)


baseUrl =
    "https://developerden.net/learning-resources/"


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


getIndexes : Task Http.Error (List LearningResourceIndex)
getIndexes =
    getTask baseUrl indexDecoder


getResources : LearningResourceIndex -> HttpTask LearningResources
getResources index =
    getTask (baseUrl ++ index.name) resourcesDecoder
