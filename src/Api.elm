module Api exposing (..)

import Effect exposing (Effect)
import Http
import Json.Decode as Json
import LearningResources.Types as LearningResources
import LearningResources.Json as LearningResources
import Yaml.Decode


type Data value
    = Loading
    | Success value
    | Failure Http.Error


getLearningResourcesIndex :
    { onResponse : Result Http.Error LearningResources.Database -> msg }
    -> Effect msg
getLearningResourcesIndex { onResponse } =
    Effect.sendCmd <|
        Http.get
            { url = "https://cdn.jsdelivr.net/gh/TheDeveloperDen/LearningResources@master/database.json"
            , expect = Http.expectJson onResponse LearningResources.decodeDatabase
            }
