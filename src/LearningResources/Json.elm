module LearningResources.Json exposing
    ( encodeCategoryLanguage, encodeCategoryPlatform, encodeCategoryTool, encodeCompiledMeta, encodeDatabase
    , encodeEntityTag, encodeFreePricing, encodeLanguageDomain, encodeMeta, encodePaidPricing, encodePricing
    , encodeProgrammingParadigm, encodeResource, encodeResourceCategory, encodeResourceType
    , decodeCategoryLanguage, decodeCategoryPlatform, decodeCategoryTool, decodeCompiledMeta, decodeDatabase
    , decodeEntityTag, decodeFreePricing, decodeLanguageDomain, decodeMeta, decodePaidPricing, decodePricing
    , decodeProgrammingParadigm, decodeResource, decodeResourceCategory, decodeResourceType
    )

{-|


## Encoders

@docs encodeCategoryLanguage, encodeCategoryPlatform, encodeCategoryTool, encodeCompiledMeta, encodeDatabase
@docs encodeEntityTag, encodeFreePricing, encodeLanguageDomain, encodeMeta, encodePaidPricing, encodePricing
@docs encodeProgrammingParadigm, encodeResource, encodeResourceCategory, encodeResourceType


## Decoders

@docs decodeCategoryLanguage, decodeCategoryPlatform, decodeCategoryTool, decodeCompiledMeta, decodeDatabase
@docs decodeEntityTag, decodeFreePricing, decodeLanguageDomain, decodeMeta, decodePaidPricing, decodePricing
@docs decodeProgrammingParadigm, decodeResource, decodeResourceCategory, decodeResourceType

-}

import Json.Decode
import Json.Encode
import LearningResources.Types
import OpenApi.Common


decodeResourceType : Json.Decode.Decoder LearningResources.Types.ResourceType
decodeResourceType =
    Json.Decode.andThen
        (\andThenUnpack ->
            case
                LearningResources.Types.resourceTypeFromString andThenUnpack
            of
                Maybe.Just a ->
                    Json.Decode.succeed a

                Maybe.Nothing ->
                    Json.Decode.fail
                        (andThenUnpack ++ " is not a valid ResourceType")
        )
        Json.Decode.string


encodeResourceType : LearningResources.Types.ResourceType -> Json.Encode.Value
encodeResourceType rec =
    Json.Encode.string (LearningResources.Types.resourceTypeToString rec)


decodeResourceCategory : Json.Decode.Decoder LearningResources.Types.ResourceCategory
decodeResourceCategory =
    Json.Decode.oneOf
        [ Json.Decode.map
            LearningResources.Types.CategoryLanguage_Or_CategoryPlatform_Or_CategoryTool__CategoryLanguage
            decodeCategoryLanguage
        , Json.Decode.map
            LearningResources.Types.CategoryLanguage_Or_CategoryPlatform_Or_CategoryTool__CategoryPlatform
            decodeCategoryPlatform
        , Json.Decode.map
            LearningResources.Types.CategoryLanguage_Or_CategoryPlatform_Or_CategoryTool__CategoryTool
            decodeCategoryTool
        ]


encodeResourceCategory : LearningResources.Types.ResourceCategory -> Json.Encode.Value
encodeResourceCategory rec =
    case rec of
        LearningResources.Types.CategoryLanguage_Or_CategoryPlatform_Or_CategoryTool__CategoryLanguage content ->
            encodeCategoryLanguage content

        LearningResources.Types.CategoryLanguage_Or_CategoryPlatform_Or_CategoryTool__CategoryPlatform content ->
            encodeCategoryPlatform content

        LearningResources.Types.CategoryLanguage_Or_CategoryPlatform_Or_CategoryTool__CategoryTool content ->
            encodeCategoryTool content


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
                decodePricing
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
                    decodeResourceType
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
            , Just ( "pricing", encodePricing rec.pricing )
            , Maybe.map
                (\mapUnpack ->
                    ( "pros", Json.Encode.list Json.Encode.string mapUnpack )
                )
                rec.pros
            , Just ( "teaches", Json.Encode.list encodeEntityTag rec.teaches )
            , Just ( "type", Json.Encode.list encodeResourceType rec.type_ )
            , Just ( "url", Json.Encode.string rec.url )
            ]
        )


decodeProgrammingParadigm : Json.Decode.Decoder LearningResources.Types.ProgrammingParadigm
decodeProgrammingParadigm =
    Json.Decode.andThen
        (\andThenUnpack ->
            case
                LearningResources.Types.programmingParadigmFromString
                    andThenUnpack
            of
                Maybe.Just a ->
                    Json.Decode.succeed a

                Maybe.Nothing ->
                    Json.Decode.fail
                        (andThenUnpack ++ " is not a valid ProgrammingParadigm")
        )
        Json.Decode.string


encodeProgrammingParadigm : LearningResources.Types.ProgrammingParadigm -> Json.Encode.Value
encodeProgrammingParadigm rec =
    Json.Encode.string (LearningResources.Types.programmingParadigmToString rec)


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


decodeMeta : Json.Decode.Decoder LearningResources.Types.Meta
decodeMeta =
    Json.Decode.succeed
        (\category description domains emoji name ->
            { category = category
            , description = description
            , domains = domains
            , emoji = emoji
            , name = name
            }
        )
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field "category" decodeResourceCategory)
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "description"
                Json.Decode.string
            )
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "domains"
                (Json.Decode.list
                    decodeLanguageDomain
                )
            )
        |> OpenApi.Common.jsonDecodeAndMap
            (OpenApi.Common.decodeOptionalField
                "emoji"
                Json.Decode.string
            )
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "name"
                Json.Decode.string
            )


encodeMeta : LearningResources.Types.Meta -> Json.Encode.Value
encodeMeta rec =
    Json.Encode.object
        (List.filterMap
            Basics.identity
            [ Just ( "category", encodeResourceCategory rec.category )
            , Just ( "description", Json.Encode.string rec.description )
            , Just
                ( "domains"
                , Json.Encode.list encodeLanguageDomain rec.domains
                )
            , Maybe.map
                (\mapUnpack -> ( "emoji", Json.Encode.string mapUnpack ))
                rec.emoji
            , Just ( "name", Json.Encode.string rec.name )
            ]
        )


decodeLanguageDomain : Json.Decode.Decoder LearningResources.Types.LanguageDomain
decodeLanguageDomain =
    Json.Decode.andThen
        (\andThenUnpack ->
            case
                LearningResources.Types.languageDomainFromString andThenUnpack
            of
                Maybe.Just a ->
                    Json.Decode.succeed a

                Maybe.Nothing ->
                    Json.Decode.fail
                        (andThenUnpack ++ " is not a valid LanguageDomain")
        )
        Json.Decode.string


encodeLanguageDomain : LearningResources.Types.LanguageDomain -> Json.Encode.Value
encodeLanguageDomain rec =
    Json.Encode.string (LearningResources.Types.languageDomainToString rec)


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
                (Json.Decode.list decodeCompiledMeta)
            )
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "resources"
                (Json.Decode.list decodeResource)
            )


encodeDatabase : LearningResources.Types.Database -> Json.Encode.Value
encodeDatabase rec =
    Json.Encode.object
        [ ( "metadata", Json.Encode.list encodeCompiledMeta rec.metadata )
        , ( "resources", Json.Encode.list encodeResource rec.resources )
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
            (Json.Decode.field "category" decodeResourceCategory)
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "description"
                Json.Decode.string
            )
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "domains"
                (Json.Decode.list
                    decodeLanguageDomain
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
            [ Just ( "category", encodeResourceCategory rec.category )
            , Just ( "description", Json.Encode.string rec.description )
            , Just
                ( "domains"
                , Json.Encode.list encodeLanguageDomain rec.domains
                )
            , Maybe.map
                (\mapUnpack -> ( "emoji", Json.Encode.string mapUnpack ))
                rec.emoji
            , Just ( "id", encodeEntityTag rec.id )
            , Just ( "name", Json.Encode.string rec.name )
            ]
        )


decodeCategoryTool : Json.Decode.Decoder LearningResources.Types.CategoryTool
decodeCategoryTool =
    Json.Decode.succeed
        (\type_ -> { type_ = type_ })
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "type"
                Json.Decode.string
            )


encodeCategoryTool : LearningResources.Types.CategoryTool -> Json.Encode.Value
encodeCategoryTool rec =
    Json.Encode.object [ ( "type", Json.Encode.string rec.type_ ) ]


decodeCategoryPlatform : Json.Decode.Decoder LearningResources.Types.CategoryPlatform
decodeCategoryPlatform =
    Json.Decode.succeed
        (\type_ -> { type_ = type_ })
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "type"
                Json.Decode.string
            )


encodeCategoryPlatform : LearningResources.Types.CategoryPlatform -> Json.Encode.Value
encodeCategoryPlatform rec =
    Json.Encode.object [ ( "type", Json.Encode.string rec.type_ ) ]


decodeCategoryLanguage : Json.Decode.Decoder LearningResources.Types.CategoryLanguage
decodeCategoryLanguage =
    Json.Decode.succeed
        (\paradigms type_ -> { paradigms = paradigms, type_ = type_ })
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field
                "paradigms"
                (Json.Decode.list decodeProgrammingParadigm)
            )
        |> OpenApi.Common.jsonDecodeAndMap
            (Json.Decode.field "type" Json.Decode.string)


encodeCategoryLanguage : LearningResources.Types.CategoryLanguage -> Json.Encode.Value
encodeCategoryLanguage rec =
    Json.Encode.object
        [ ( "paradigms"
          , Json.Encode.list encodeProgrammingParadigm rec.paradigms
          )
        , ( "type", Json.Encode.string rec.type_ )
        ]
