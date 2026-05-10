module Api exposing (..)

import Effect exposing (Effect)
import Http
import Json.Decode as Json
import LearningResources


type Data value
    = Loading
    | Success value
    | Failure Http.Error


getLearningResourcesIndex :
    { onResponse : Result Http.Error (List LearningResources.ResourceIndexEntry) -> msg }
    -> Effect msg
getLearningResourcesIndex { onResponse } =
    Effect.sendCmd <|
        Http.get
            { url = "https://learningresources.developerden.org"
            , expect = Http.expectJson onResponse resourceIndexDecoder
            }


resourceIndexDecoder : Json.Decoder (List LearningResources.ResourceIndexEntry)
resourceIndexDecoder =
    Json.list
        (Json.map LearningResources.ResourceIndexEntry
            (Json.field "name" Json.string)
        )


toUserFriendlyMessage : Http.Error -> String
toUserFriendlyMessage httpError =
    case httpError of
        Http.BadUrl _ ->
            "This page requested a bad URL"

        Http.Timeout ->
            "Request took too long to respond"

        Http.NetworkError ->
            "Could not connect to the API"

        Http.BadStatus code ->
            if code == 404 then
                "Item not found"

            else
                "API returned an error code"

        Http.BadBody _ ->
            "Unexpected response from API"
