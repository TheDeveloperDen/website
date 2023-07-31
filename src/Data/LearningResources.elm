module Data.LearningResources exposing (..)

-- Set of resources that can be used for learning programming

import Data.Encode as Encode
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline
    exposing
        ( optional
        , required
        )
import Json.Encode as Encode exposing (Value)


type alias LearningResources =
    { description : String
    , emoji : Maybe String
    , name : String
    , resources : List Resource
    }


type Price
    = Price_S String
    | Price_F Float


type alias Resource =
    { cons : List String
    , name : String
    , price : Maybe Price
    , pros : List String
    , url : String
    }


learningResourcesDecoder : Decoder LearningResources
learningResourcesDecoder =
    Decode.succeed LearningResources
        |> required "description" Decode.string
        |> optional "emoji" (Decode.nullable Decode.string) Nothing
        |> required "name" Decode.string
        |> required "resources" resourcesDecoder


priceDecoder : Decoder Price
priceDecoder =
    Decode.oneOf
        [ Decode.string |> Decode.map Price_S
        , Decode.float |> Decode.map Price_F
        ]


resourceDecoder : Decoder Resource
resourceDecoder =
    Decode.succeed Resource
        |> required "cons" (Decode.list Decode.string)
        |> required "name" Decode.string
        |> optional "price" (Decode.nullable priceDecoder) Nothing
        |> required "pros" (Decode.list Decode.string)
        |> required "url" Decode.string


resourcesDecoder : Decoder (List Resource)
resourcesDecoder =
    Decode.list resourceDecoder


encodeLanguageResources : LearningResources -> Value
encodeLanguageResources learningResources =
    []
        |> Encode.required "description" learningResources.description Encode.string
        |> Encode.optional "emoji" learningResources.emoji Encode.string
        |> Encode.required "name" learningResources.name Encode.string
        |> Encode.required "resources" learningResources.resources encodeResources
        |> Encode.object


encodePrice : Price -> Value
encodePrice price =
    case price of
        Price_S stringValue ->
            Encode.string stringValue

        Price_F floatValue ->
            Encode.float floatValue


encodeResource : Resource -> Value
encodeResource resource =
    []
        |> Encode.required "cons" resource.cons (Encode.list Encode.string)
        |> Encode.required "name" resource.name Encode.string
        |> Encode.optional "price" resource.price encodePrice
        |> Encode.required "pros" resource.pros (Encode.list Encode.string)
        |> Encode.required "url" resource.url Encode.string
        |> Encode.object


encodeResources : List Resource -> Value
encodeResources resources =
    resources
        |> Encode.list encodeResource
