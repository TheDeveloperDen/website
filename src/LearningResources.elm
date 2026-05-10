module LearningResources exposing
    ( LearningResourcesSet
    , Price(..)
    , Resource
    , ResourceIndexEntry
    , learningResourcesSet
    , learningResourcesSetToString
    )

import Dict exposing (Dict)
import Yaml.Decode as Jdec
import Yaml.Encode as Jenc


type alias ResourceIndexEntry =
    { name : String
    }


{-| Set of resources that can be used for learning programming

description:
A brief description of the language and its uses

emoji:
A Unicode emoji glyph or Discord emoji ID to represent the resource, if applicable. The
emoji must be part of the main DevDen server, which isn't great design but there's not
really a better way of doing it.

name:
The name of the language

resources:
List of resources that can be used for learning / practicing the language

-}
type alias LearningResourcesSet =
    { description : String
    , emoji : Maybe String
    , name : String
    , resources : List Resource
    }


{-| cons:
Array of cons for using the resource, e.g. 'only teaches the basics rather than more
advanced concepts'

description:
A brief description of the resource

name:
The official name of the resource

price:
The price of the resource, if it has one. If the resource is free, omit this field.

pros:
Array of pros for using the resource, e.g. 'explains difficult concepts with good
analogies'

url:
URL to the resource

-}
type alias Resource =
    { cons : List String
    , description : Maybe String
    , name : String
    , price : Maybe Price
    , pros : List String
    , url : String
    }


{-| The price of the resource, if it has one. If the resource is free, omit this field.
-}
type Price
    = DoubleInPrice Float
    | StringInPrice String



-- decoders and encoders


learningResourcesSetToString : LearningResourcesSet -> String
learningResourcesSetToString r =
    Jenc.toString 0 (encodeLearningResourcesSet r)


learningResourcesSet : Jdec.Decoder LearningResourcesSet
learningResourcesSet =
    Jdec.map4 LearningResourcesSet
        (Jdec.field "description" Jdec.string)
        (optionalField "emoji" Jdec.string)
        (Jdec.field "name" Jdec.string)
        (Jdec.field "resources" (Jdec.list resource))


encodeLearningResourcesSet : LearningResourcesSet -> Jenc.Encoder
encodeLearningResourcesSet x =
    Jenc.record
        [ ( "description", Jenc.string x.description )
        , ( "emoji", makeNullableEncoder Jenc.string x.emoji )
        , ( "name", Jenc.string x.name )
        , ( "resources", makeListEncoder encodeResource x.resources )
        ]


resource : Jdec.Decoder Resource
resource =
    Jdec.map6 Resource
        (Jdec.field "cons" (Jdec.list Jdec.string))
        (optionalField "description" Jdec.string)
        (Jdec.field "name" Jdec.string)
        (optionalField "price" price)
        (Jdec.field "pros" (Jdec.list Jdec.string))
        (Jdec.field "url" Jdec.string)


encodeResource : Resource -> Jenc.Encoder
encodeResource x =
    Jenc.record
        [ ( "cons", makeListEncoder Jenc.string x.cons )
        , ( "description", makeNullableEncoder Jenc.string x.description )
        , ( "name", Jenc.string x.name )
        , ( "price", makeNullableEncoder encodePrice x.price )
        , ( "pros", makeListEncoder Jenc.string x.pros )
        , ( "url", Jenc.string x.url )
        ]


price : Jdec.Decoder Price
price =
    Jdec.oneOf
        [ Jdec.map StringInPrice Jdec.string
        , Jdec.map DoubleInPrice Jdec.float
        ]


optionalField : String -> Jdec.Decoder a -> Jdec.Decoder (Maybe a)
optionalField name decoder =
    Jdec.oneOf
        [ Jdec.field name (Jdec.nullable decoder)
        , Jdec.succeed Nothing
        ]


encodePrice : Price -> Jenc.Encoder
encodePrice x =
    case x of
        StringInPrice y ->
            Jenc.string y

        DoubleInPrice y ->
            Jenc.float y



--- encoder helpers


makeListEncoder : (a -> Jenc.Encoder) -> List a -> Jenc.Encoder
makeListEncoder f arr =
    Jenc.list f arr


makeNullableEncoder : (a -> Jenc.Encoder) -> Maybe a -> Jenc.Encoder
makeNullableEncoder f m =
    case m of
        Just x ->
            f x

        Nothing ->
            Jenc.null
