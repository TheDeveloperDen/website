module Util exposing (..)

import Http exposing (Error(..), Expect, Response(..), expectStringResponse)
import Yaml.Decode as Decode


expectYaml : (Result Error a -> msg) -> Decode.Decoder a -> Expect msg
expectYaml toMsg decoder =
    expectStringResponse toMsg <|
        resolve <|
            \string ->
                Result.mapError Decode.errorToString (Decode.fromString decoder string)


resolve : (body -> Result String a) -> Response body -> Result Error a
resolve toResult response =
    case response of
        BadUrl_ url ->
            Err (BadUrl url)

        Timeout_ ->
            Err Timeout

        NetworkError_ ->
            Err NetworkError

        BadStatus_ metadata _ ->
            Err (BadStatus metadata.statusCode)

        GoodStatus_ _ body ->
            Result.mapError BadBody (toResult body)
