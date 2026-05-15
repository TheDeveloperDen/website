module Api exposing (Data(..), getLearningResourcesIndex)

import Effect exposing (Effect)
import Http
import LearningResources.Json as LearningResources
import LearningResources.Types as LearningResources


type Data value
    = Success value


getLearningResourcesIndex :
    { onResponse : Result Http.Error LearningResources.Database -> msg }
    -> Effect msg
getLearningResourcesIndex { onResponse } =
    Effect.sendCmd <|
        Http.get
            { url = "https://cdn.jsdelivr.net/gh/TheDeveloperDen/LearningResources@master/database.json"
            , expect = Http.expectJson onResponse LearningResources.decodeDatabase
            }
