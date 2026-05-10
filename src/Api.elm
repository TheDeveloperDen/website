module Api exposing (..)

import Effect exposing (Effect)
import Http
import Json.Decode as Json
import LearningResources
import Yaml.Decode


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


getLearningResource :
    { name : String
    , onResponse : Result Http.Error LearningResources.LearningResourcesSet -> msg
    }
    -> Effect msg
getLearningResource { name, onResponse } =
    Effect.sendCmd <|
        Http.get
            { url = "https://learningresources.developerden.org/" ++ name
            , expect =
                expectYaml onResponse LearningResources.learningResourcesSet
            }

expectYaml : (Result Http.Error a -> msg) -> Yaml.Decode.Decoder a -> Http.Expect msg
expectYaml toMsg decoder = 
    Http.expectStringResponse toMsg <| resolve decoder

resolve decoder = \response ->
      case response of
        Http.BadUrl_ url ->
          Err (Http.BadUrl url)

        Http.Timeout_ ->
          Err Http.Timeout

        Http.NetworkError_ ->
          Err Http.NetworkError

        Http.BadStatus_ metadata body ->
          Err (Http.BadStatus metadata.statusCode)

        Http.GoodStatus_ metadata body ->
          case Yaml.Decode.fromString decoder body of
            Ok value ->
              Ok value

            Err err ->
              Err (Http.BadBody (Yaml.Decode.errorToString err))


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
