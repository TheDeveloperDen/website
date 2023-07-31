module Data.Encode exposing (optional, required)

-- Helper functions for encoding JSON objects.

import Json.Encode exposing (Value)


required :
    String
    -> a
    -> (a -> Value)
    -> List ( String, Value )
    -> List ( String, Value )
required key value encode properties =
    properties ++ [ ( key, encode value ) ]


optional :
    String
    -> Maybe a
    -> (a -> Value)
    -> List ( String, Value )
    -> List ( String, Value )
optional key maybe encode properties =
    case maybe of
        Just value ->
            properties ++ [ ( key, encode value ) ]

        Nothing ->
            properties
