module LearningResources.Json exposing
    ( encodeCompiledMeta, encodeDatabase, encodeEntityTag, encodeFreePricing, encodePaidPricing, encodePricing
    , encodeResource, encodeResourceCategory
    , decodeCompiledMeta, decodeDatabase, decodeEntityTag, decodeFreePricing, decodePaidPricing, decodePricing
    , decodeResource, decodeResourceCategory
    )

{-|


## Encoders

@docs encodeCompiledMeta, encodeDatabase, encodeEntityTag, encodeFreePricing, encodePaidPricing, encodePricing
@docs encodeResource, encodeResourceCategory


## Decoders

@docs decodeCompiledMeta, decodeDatabase, decodeEntityTag, decodeFreePricing, decodePaidPricing, decodePricing
@docs decodeResource, decodeResourceCategory

-}

import Json.Decode
import Json.Encode
import LearningResources.Types
import OpenApi.Common


decodeResourceCategory : Json.Decode.Decoder LearningResources.Types.ResourceCategory
decodeResourceCategory =
    Json.Decode.value


encodeResourceCategory : LearningResources.Types.ResourceCategory -> Json.Encode.Value
encodeResourceCategory =
    Basics.identity


decodeResource : Json.Decode.Decoder LearningResources.Types.Resource
decodeResource =
    Json.Decode.succeed
        (\cons description name pricing pros teaches type_ url ->
            { cons = cons
            , description = description
            , name = name
            , pricing = pricing
            , pros = pros
            , teaches = teaches
            , type_ = type_
            , url = url
            }
        )
        |> OpenApi.Common.jsonDecodeAndMap
            (OpenApi.Common.decodeOptionalField
                "cons"
                (Json.Decode.list Json.Decode.string)
            )
        |> OpenApi.Common.jsonDecodeAndMap
            (OpenApi.Common.decodeOptionalField
                "description"
                Json.Decode.string
            )
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "name"
                Json.Decode.string
            )
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "pricing"
                (Json.Decode.oneOf
                    [ Json.Decode.map
                        LearningResources.Types.FreePricing_Or_PaidPricing__FreePricing
                        decodeFreePricing
                    , Json.Decode.map
                        LearningResources.Types.FreePricing_Or_PaidPricing__PaidPricing
                        decodePaidPricing
                    ]
                )
            )
        |> OpenApi.Common.jsonDecodeAndMap
            (OpenApi.Common.decodeOptionalField
                "pros"
                (Json.Decode.list
                    Json.Decode.string
                )
            )
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "teaches"
                (Json.Decode.list
                    decodeEntityTag
                )
            )
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "type"
                (Json.Decode.list
                    Json.Decode.string
                )
            )
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "url"
                Json.Decode.string
            )


encodeResource : LearningResources.Types.Resource -> Json.Encode.Value
encodeResource rec =
    Json.Encode.object
        (List.filterMap
            Basics.identity
            [ Maybe.map
                (\mapUnpack ->
                    ( "cons", Json.Encode.list Json.Encode.string mapUnpack )
                )
                rec.cons
            , Maybe.map
                (\mapUnpack -> ( "description", Json.Encode.string mapUnpack ))
                rec.description
            , Just ( "name", Json.Encode.string rec.name )
            , Just
                ( "pricing"
                , case rec.pricing of
                    LearningResources.Types.FreePricing_Or_PaidPricing__FreePricing content ->
                        encodeFreePricing content

                    LearningResources.Types.FreePricing_Or_PaidPricing__PaidPricing content ->
                        encodePaidPricing content
                )
            , Maybe.map
                (\mapUnpack ->
                    ( "pros", Json.Encode.list Json.Encode.string mapUnpack )
                )
                rec.pros
            , Just ( "teaches", Json.Encode.list encodeEntityTag rec.teaches )
            , Just ( "type", Json.Encode.list Json.Encode.string rec.type_ )
            , Just ( "url", Json.Encode.string rec.url )
            ]
        )


decodePricing : Json.Decode.Decoder LearningResources.Types.Pricing
decodePricing =
    Json.Decode.oneOf
        [ Json.Decode.map
            LearningResources.Types.FreePricing_Or_PaidPricing__FreePricing
            decodeFreePricing
        , Json.Decode.map
            LearningResources.Types.FreePricing_Or_PaidPricing__PaidPricing
            decodePaidPricing
        ]


encodePricing : LearningResources.Types.Pricing -> Json.Encode.Value
encodePricing rec =
    case rec of
        LearningResources.Types.FreePricing_Or_PaidPricing__FreePricing content ->
            encodeFreePricing content

        LearningResources.Types.FreePricing_Or_PaidPricing__PaidPricing content ->
            encodePaidPricing content


decodePaidPricing : Json.Decode.Decoder LearningResources.Types.PaidPricing
decodePaidPricing =
    Json.Decode.succeed
        (\amount model -> { amount = amount, model = model })
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field "amount" Json.Decode.float)
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field "model" Json.Decode.string)


encodePaidPricing : LearningResources.Types.PaidPricing -> Json.Encode.Value
encodePaidPricing rec =
    Json.Encode.object
        [ ( "amount", Json.Encode.float rec.amount )
        , ( "model", Json.Encode.string rec.model )
        ]


decodeFreePricing : Json.Decode.Decoder LearningResources.Types.FreePricing
decodeFreePricing =
    Json.Decode.succeed
        (\model -> { model = model })
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "model"
                Json.Decode.string
            )


encodeFreePricing : LearningResources.Types.FreePricing -> Json.Encode.Value
encodeFreePricing rec =
    Json.Encode.object [ ( "model", Json.Encode.string rec.model ) ]


decodeEntityTag : Json.Decode.Decoder LearningResources.Types.EntityTag
decodeEntityTag =
    Json.Decode.andThen
        (\andThenUnpack ->
            case LearningResources.Types.entityTagFromString andThenUnpack of
                Maybe.Just a ->
                    Json.Decode.succeed a

                Maybe.Nothing ->
                    Json.Decode.fail
                        (andThenUnpack ++ " is not a valid EntityTag")
        )
        Json.Decode.string


encodeEntityTag : LearningResources.Types.EntityTag -> Json.Encode.Value
encodeEntityTag rec =
    Json.Encode.string (LearningResources.Types.entityTagToString rec)


decodeDatabase : Json.Decode.Decoder LearningResources.Types.Database
decodeDatabase =
    Json.Decode.succeed
        (\metadata resources -> { metadata = metadata, resources = resources })
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "metadata"
                (Json.Decode.list
                    (Json.Decode.succeed
                        (\category description domains emoji id name ->
                            { category = category
                            , description =
                                description
                            , domains = domains
                            , emoji = emoji
                            , id = id
                            , name = name
                            }
                        )
                        |> OpenApi.Common.jsonDecodeAndMap
                            (Json.Decode.field
                                "category"
                                Json.Decode.value
                            )
                        |> OpenApi.Common.jsonDecodeAndMap
                            (Json.Decode.field
                                "description"
                                Json.Decode.string
                            )
                        |> OpenApi.Common.jsonDecodeAndMap
                            (Json.Decode.field
                                "domains"
                                (Json.Decode.list
                                    Json.Decode.string
                                )
                            )
                        |> OpenApi.Common.jsonDecodeAndMap
                            (OpenApi.Common.decodeOptionalField
                                "emoji"
                                Json.Decode.string
                            )
                        |> OpenApi.Common.jsonDecodeAndMap
                            (Json.Decode.field
                                "id"
                                decodeEntityTag
                            )
                        |> OpenApi.Common.jsonDecodeAndMap
                            (Json.Decode.field
                                "name"
                                Json.Decode.string
                            )
                    )
                )
            )
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "resources"
                (Json.Decode.list
                    (Json.Decode.succeed
                        (\cons description name pricing pros teaches type_ url ->
                            { cons =
                                cons
                            , description =
                                description
                            , name =
                                name
                            , pricing =
                                pricing
                            , pros =
                                pros
                            , teaches =
                                teaches
                            , type_ =
                                type_
                            , url =
                                url
                            }
                        )
                        |> OpenApi.Common.jsonDecodeAndMap
                            (OpenApi.Common.decodeOptionalField
                                "cons"
                                (Json.Decode.list
                                    Json.Decode.string
                                )
                            )
                        |> OpenApi.Common.jsonDecodeAndMap
                            (OpenApi.Common.decodeOptionalField
                                "description"
                                Json.Decode.string
                            )
                        |> OpenApi.Common.jsonDecodeAndMap
                            (Json.Decode.field
                                "name"
                                Json.Decode.string
                            )
                        |> OpenApi.Common.jsonDecodeAndMap
                            (Json.Decode.field
                                "pricing"
                                (Json.Decode.oneOf
                                    [ Json.Decode.map
                                        LearningResources.Types.FreePricing_Or_PaidPricing__FreePricing
                                        decodeFreePricing
                                    , Json.Decode.map
                                        LearningResources.Types.FreePricing_Or_PaidPricing__PaidPricing
                                        decodePaidPricing
                                    ]
                                )
                            )
                        |> OpenApi.Common.jsonDecodeAndMap
                            (OpenApi.Common.decodeOptionalField
                                "pros"
                                (Json.Decode.list
                                    Json.Decode.string
                                )
                            )
                        |> OpenApi.Common.jsonDecodeAndMap
                            (Json.Decode.field
                                "teaches"
                                (Json.Decode.list
                                    decodeEntityTag
                                )
                            )
                        |> OpenApi.Common.jsonDecodeAndMap
                            (Json.Decode.field
                                "type"
                                (Json.Decode.list
                                    Json.Decode.string
                                )
                            )
                        |> OpenApi.Common.jsonDecodeAndMap
                            (Json.Decode.field
                                "url"
                                Json.Decode.string
                            )
                    )
                )
            )


encodeDatabase : LearningResources.Types.Database -> Json.Encode.Value
encodeDatabase rec =
    Json.Encode.object
        [ ( "metadata"
          , Json.Encode.list
                (\rec0 ->
                    Json.Encode.object
                        (List.filterMap
                            Basics.identity
                            [ Just
                                ( "category", Basics.identity rec0.category )
                            , Just
                                ( "description"
                                , Json.Encode.string rec0.description
                                )
                            , Just
                                ( "domains"
                                , Json.Encode.list
                                    Json.Encode.string
                                    rec0.domains
                                )
                            , Maybe.map
                                (\mapUnpack ->
                                    ( "emoji", Json.Encode.string mapUnpack )
                                )
                                rec0.emoji
                            , Just ( "id", encodeEntityTag rec0.id )
                            , Just ( "name", Json.Encode.string rec0.name )
                            ]
                        )
                )
                rec.metadata
          )
        , ( "resources"
          , Json.Encode.list
                (\rec0 ->
                    Json.Encode.object
                        (List.filterMap
                            Basics.identity
                            [ Maybe.map
                                (\mapUnpack ->
                                    ( "cons"
                                    , Json.Encode.list
                                        Json.Encode.string
                                        mapUnpack
                                    )
                                )
                                rec0.cons
                            , Maybe.map
                                (\mapUnpack ->
                                    ( "description"
                                    , Json.Encode.string mapUnpack
                                    )
                                )
                                rec0.description
                            , Just ( "name", Json.Encode.string rec0.name )
                            , Just
                                ( "pricing"
                                , case rec0.pricing of
                                    LearningResources.Types.FreePricing_Or_PaidPricing__FreePricing content ->
                                        encodeFreePricing content

                                    LearningResources.Types.FreePricing_Or_PaidPricing__PaidPricing content ->
                                        encodePaidPricing content
                                )
                            , Maybe.map
                                (\mapUnpack ->
                                    ( "pros"
                                    , Json.Encode.list
                                        Json.Encode.string
                                        mapUnpack
                                    )
                                )
                                rec0.pros
                            , Just
                                ( "teaches"
                                , Json.Encode.list
                                    encodeEntityTag
                                    rec0.teaches
                                )
                            , Just
                                ( "type"
                                , Json.Encode.list
                                    Json.Encode.string
                                    rec0.type_
                                )
                            , Just ( "url", Json.Encode.string rec0.url )
                            ]
                        )
                )
                rec.resources
          )
        ]


decodeCompiledMeta : Json.Decode.Decoder LearningResources.Types.CompiledMeta
decodeCompiledMeta =
    Json.Decode.succeed
        (\category description domains emoji id name ->
            { category = category
            , description = description
            , domains = domains
            , emoji = emoji
            , id = id
            , name = name
            }
        )
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field "category" Json.Decode.value)
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "description"
                Json.Decode.string
            )
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "domains"
                (Json.Decode.list
                    Json.Decode.string
                )
            )
        |> OpenApi.Common.jsonDecodeAndMap
            (OpenApi.Common.decodeOptionalField
                "emoji"
                Json.Decode.string
            )
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "id"
                decodeEntityTag
            )
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "name"
                Json.Decode.string
            )


encodeCompiledMeta : LearningResources.Types.CompiledMeta -> Json.Encode.Value
encodeCompiledMeta rec =
    Json.Encode.object
        (List.filterMap
            Basics.identity
            [ Just ( "category", Basics.identity rec.category )
            , Just ( "description", Json.Encode.string rec.description )
            , Just
                ( "domains", Json.Encode.list Json.Encode.string rec.domains )
            , Maybe.map
                (\mapUnpack -> ( "emoji", Json.Encode.string mapUnpack ))
                rec.emoji
            , Just ( "id", encodeEntityTag rec.id )
            , Just ( "name", Json.Encode.string rec.name )
            ]
        )
