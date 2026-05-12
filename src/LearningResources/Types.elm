module LearningResources.Types exposing
    ( CompiledMeta, Database, FreePricing, PaidPricing, Pricing, Resource, ResourceCategory
    , EntityTag(..), entityTagFromString, entityTagToString, entityTagVariants
    , FreePricing_Or_PaidPricing(..)
    )

{-|


## Aliases

@docs CompiledMeta, Database, FreePricing, PaidPricing, Pricing, Resource, ResourceCategory


## Enum

@docs EntityTag, entityTagFromString, entityTagToString, entityTagVariants


## One of

@docs FreePricing_Or_PaidPricing

-}

import Json.Encode


{-| The category of the resource
-}
type alias ResourceCategory =
    Json.Encode.Value


{-| Fields:

  - cons: Array of cons for using the resource, e.g. 'only teaches the basics rather than more advanced concepts'

  - description: A brief description of the resource

  - name: The official name of the resource

  - pricing: Details about the cost of the resource.

  - pros: Array of pros for using the resource, e.g. 'explains difficult concepts with good analogies'

  - teaches: The topics that this resource teaches.

  - type: The type(s) of the resource, e.g. 'Video', 'Book', 'Course', etc.

    A list of: The type of the resource

  - url: URL to the resource

-}
type alias Resource =
    { cons : Maybe (List String)
    , description : Maybe String
    , name : String
    , pricing : FreePricing_Or_PaidPricing
    , pros : Maybe (List String)
    , teaches : List EntityTag
    , type_ : List String
    , url : String
    }


{-| Details about the cost of the resource.
-}
type alias Pricing =
    FreePricing_Or_PaidPricing


{-| Fields:

  - amount: The price of this resource, in US Dollars.
  - model: The Paid Pricing Model of this resource. 'Subscription' means the resource is paid on a recurring basis (e.g. monthly or yearly), while 'One Time' means the resource is paid with a single upfront payment. If the price varies or is not fixed, provide a close approximation. Note that the subscription renewal cycle is not specified, so if the price has different renewal cycles, provide the most common or default one (usually monthly).

-}
type alias PaidPricing =
    { amount : Float, model : String }


{-| Fields:

  - model: The Free(mium) Pricing Model of this resource. 'Free' should be used for resources where 100% (or close) of the content is free. 'Freemium' describes a pricing model where the core content is available for free, but features paid extensions. If the resource has a freemium model but the free portion is very limited, consider using 'Paid' instead and providing an estimated price for the full version.

-}
type alias FreePricing =
    { model : String }


type EntityTag
    = EntityTag__Clojure
    | EntityTag__Cpp
    | EntityTag__General
    | EntityTag__Git
    | EntityTag__Haskell
    | EntityTag__Java
    | EntityTag__Kotlin
    | EntityTag__Php
    | EntityTag__ProgrammingLanguageDesign
    | EntityTag__Python
    | EntityTag__Rust
    | EntityTag__Sql


entityTagToString : EntityTag -> String
entityTagToString value =
    case value of
        EntityTag__Clojure ->
            "clojure"

        EntityTag__Cpp ->
            "cpp"

        EntityTag__General ->
            "general"

        EntityTag__Git ->
            "git"

        EntityTag__Haskell ->
            "haskell"

        EntityTag__Java ->
            "java"

        EntityTag__Kotlin ->
            "kotlin"

        EntityTag__Php ->
            "php"

        EntityTag__ProgrammingLanguageDesign ->
            "programming-language-design"

        EntityTag__Python ->
            "python"

        EntityTag__Rust ->
            "rust"

        EntityTag__Sql ->
            "sql"


entityTagFromString : String -> Maybe EntityTag
entityTagFromString value =
    case value of
        "clojure" ->
            Just EntityTag__Clojure

        "cpp" ->
            Just EntityTag__Cpp

        "general" ->
            Just EntityTag__General

        "git" ->
            Just EntityTag__Git

        "haskell" ->
            Just EntityTag__Haskell

        "java" ->
            Just EntityTag__Java

        "kotlin" ->
            Just EntityTag__Kotlin

        "php" ->
            Just EntityTag__Php

        "programming-language-design" ->
            Just EntityTag__ProgrammingLanguageDesign

        "python" ->
            Just EntityTag__Python

        "rust" ->
            Just EntityTag__Rust

        "sql" ->
            Just EntityTag__Sql

        _ ->
            Nothing


entityTagVariants : List EntityTag
entityTagVariants =
    [ EntityTag__Clojure
    , EntityTag__Cpp
    , EntityTag__General
    , EntityTag__Git
    , EntityTag__Haskell
    , EntityTag__Java
    , EntityTag__Kotlin
    , EntityTag__Php
    , EntityTag__ProgrammingLanguageDesign
    , EntityTag__Python
    , EntityTag__Rust
    , EntityTag__Sql
    ]


{-| Fields:

  - metadata: List of all entities in the system

    A list of:
    Fields:

        - category: The category of the resource
        - description: A brief description of the language, tool, etc being described by this metadata.
        - domains: The domain(s) that the entity is commonly used in, or best suited for.

             A list of: A domain that a programming language may be used in.
        - emoji: A Unicode emoji glyph to represent the entity, if applicable. If there is no suitable (Unicode) emoji, omit this field. Consumers may choose to ignore this field, or replace it with a custom image.
        - id: The unique identifier of the entity
        - name: The name of the language, tool, etc being described by this metadata.

  - resources: List of all learning resources

    A list of:
    Fields:

        - cons: Array of cons for using the resource, e.g. 'only teaches the basics rather than more advanced concepts'
        - description: A brief description of the resource
        - name: The official name of the resource
        - pricing: Details about the cost of the resource.
        - pros: Array of pros for using the resource, e.g. 'explains difficult concepts with good analogies'
        - teaches: The topics that this resource teaches.
        - type: The type(s) of the resource, e.g. 'Video', 'Book', 'Course', etc.

             A list of: The type of the resource
        - url: URL to the resource

-}
type alias Database =
    { metadata :
        List
            { category : Json.Encode.Value
            , description : String
            , domains : List String
            , emoji : Maybe String
            , id : EntityTag
            , name : String
            }
    , resources :
        List
            { cons : Maybe (List String)
            , description : Maybe String
            , name : String
            , pricing : FreePricing_Or_PaidPricing
            , pros : Maybe (List String)
            , teaches : List EntityTag
            , type_ : List String
            , url : String
            }
    }


{-| Fields:

  - category: The category of the resource

  - description: A brief description of the language, tool, etc being described by this metadata.

  - domains: The domain(s) that the entity is commonly used in, or best suited for.

    A list of: A domain that a programming language may be used in.

  - emoji: A Unicode emoji glyph to represent the entity, if applicable. If there is no suitable (Unicode) emoji, omit this field. Consumers may choose to ignore this field, or replace it with a custom image.

  - id: The unique identifier of the entity

  - name: The name of the language, tool, etc being described by this metadata.

-}
type alias CompiledMeta =
    { category : Json.Encode.Value
    , description : String
    , domains : List String
    , emoji : Maybe String
    , id : EntityTag
    , name : String
    }


type FreePricing_Or_PaidPricing
    = FreePricing_Or_PaidPricing__FreePricing FreePricing
    | FreePricing_Or_PaidPricing__PaidPricing PaidPricing
