module Data.LearningResources exposing (..)

-- Set of resources that can be used for learning programming

import Data.Encode as Encode
import Yaml.Decode as Decode exposing (Decoder)



-- import Yaml.Decode.Pipeline
--     exposing
--         ( optional
--         , required
--         )
-- import Json.Encode as Encode exposing (Value)


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
    Decode.map4 LearningResources
        (Decode.field "description" Decode.string)
        (Decode.field "emoji" (Decode.nullable Decode.string))
        (Decode.field "name" Decode.string)
        (Decode.field "resources" resourcesDecoder)


priceDecoder : Decoder Price
priceDecoder =
    Decode.oneOf
        [ Decode.string |> Decode.map Price_S
        , Decode.float |> Decode.map Price_F
        ]


resourceDecoder : Decoder Resource
resourceDecoder =
    Decode.map5 Resource
        (Decode.field "cons" (Decode.list Decode.string))
        (Decode.field "name" Decode.string)
        (Decode.maybe <| Decode.field "price" priceDecoder)
        (Decode.field "pros" (Decode.list Decode.string))
        (Decode.field "url" Decode.string)


resourcesDecoder : Decoder (List Resource)
resourcesDecoder =
    Decode.list resourceDecoder



-- encodeLanguageResources : LearningResources -> Value
-- encodeLanguageResources learningResources =
--     []
--         |> Encode.required "description" learningResources.description Encode.string
--         |> Encode.optional "emoji" learningResources.emoji Encode.string
--         |> Encode.required "name" learningResources.name Encode.string
--         |> Encode.required "resources" learningResources.resources encodeResources
--         |> Encode.object
-- encodePrice : Price -> Value
-- encodePrice price =
--     case price of
--         Price_S stringValue ->
--             Encode.string stringValue
--         Price_F floatValue ->
--             Encode.float floatValue
-- encodeResource : Resource -> Value
-- encodeResource resource =
--     []
--         |> Encode.required "cons" resource.cons (Encode.list Encode.string)
--         |> Encode.required "name" resource.name Encode.string
--         |> Encode.optional "price" resource.price encodePrice
--         |> Encode.required "pros" resource.pros (Encode.list Encode.string)
--         |> Encode.required "url" resource.url Encode.string
--         |> Encode.object
-- encodeResources : List Resource -> Value
-- encodeResources resources =
--     resources
--         |> Encode.list encodeResource
