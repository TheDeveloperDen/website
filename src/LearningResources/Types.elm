module LearningResources.Types exposing
    ( CategoryLanguage, CategoryPlatform, CategoryTool, CompiledMeta, Database, FreePricing, Meta, PaidPricing
    , Pricing, Resource, ResourceCategory
    , EntityTag(..), LanguageDomain(..), ProgrammingParadigm(..), ResourceType(..), entityTagFromString, entityTagToString
    , entityTagVariants, languageDomainFromString, languageDomainToString, languageDomainVariants
    , programmingParadigmFromString, programmingParadigmToString, programmingParadigmVariants
    , resourceTypeFromString, resourceTypeToString, resourceTypeVariants
    , CategoryLanguage_Or_CategoryPlatform_Or_CategoryTool(..), FreePricing_Or_PaidPricing(..)
    )

{-|


## Aliases

@docs CategoryLanguage, CategoryPlatform, CategoryTool, CompiledMeta, Database, FreePricing, Meta, PaidPricing
@docs Pricing, Resource, ResourceCategory


## Enum

@docs EntityTag, LanguageDomain, ProgrammingParadigm, ResourceType, entityTagFromString, entityTagToString
@docs entityTagVariants, languageDomainFromString, languageDomainToString, languageDomainVariants
@docs programmingParadigmFromString, programmingParadigmToString, programmingParadigmVariants
@docs resourceTypeFromString, resourceTypeToString, resourceTypeVariants


## One of

@docs CategoryLanguage_Or_CategoryPlatform_Or_CategoryTool, FreePricing_Or_PaidPricing

-}


{-| The type of the resource
-}
type ResourceType
    = ResourceType__Article
    | ResourceType__Book
    | ResourceType__Course
    | ResourceType__InteractiveTutorial
    | ResourceType__Video


resourceTypeToString : ResourceType -> String
resourceTypeToString value =
    case value of
        ResourceType__Article ->
            "Article"

        ResourceType__Book ->
            "Book"

        ResourceType__Course ->
            "Course"

        ResourceType__InteractiveTutorial ->
            "Interactive Tutorial"

        ResourceType__Video ->
            "Video"


resourceTypeFromString : String -> Maybe ResourceType
resourceTypeFromString value =
    case value of
        "Article" ->
            Just ResourceType__Article

        "Book" ->
            Just ResourceType__Book

        "Course" ->
            Just ResourceType__Course

        "Interactive Tutorial" ->
            Just ResourceType__InteractiveTutorial

        "Video" ->
            Just ResourceType__Video

        _ ->
            Nothing


resourceTypeVariants : List ResourceType
resourceTypeVariants =
    [ ResourceType__Article
    , ResourceType__Book
    , ResourceType__Course
    , ResourceType__InteractiveTutorial
    , ResourceType__Video
    ]


type alias ResourceCategory =
    CategoryLanguage_Or_CategoryPlatform_Or_CategoryTool


{-| Fields:

  - cons: Array of cons for using the resource, e.g. 'only teaches the basics rather than more advanced concepts'
  - description: A brief description of the resource
  - name: The official name of the resource
  - pros: Array of pros for using the resource, e.g. 'explains difficult concepts with good analogies'
  - teaches: The topics that this resource teaches.
  - type: The type(s) of the resource, e.g. 'Video', 'Book', 'Course', etc.
  - url: URL to the resource

-}
type alias Resource =
    { cons : Maybe (List String)
    , description : Maybe String
    , name : String
    , pricing : Pricing
    , pros : Maybe (List String)
    , teaches : List EntityTag
    , type_ : List ResourceType
    , url : String
    }


{-| A programming paradigm.
-}
type ProgrammingParadigm
    = ProgrammingParadigm__FunctionalProgramming
    | ProgrammingParadigm__LogicProgramming
    | ProgrammingParadigm__ObjectOrientedProgramming
    | ProgrammingParadigm__ProceduralProgramming


programmingParadigmToString : ProgrammingParadigm -> String
programmingParadigmToString value =
    case value of
        ProgrammingParadigm__FunctionalProgramming ->
            "Functional Programming"

        ProgrammingParadigm__LogicProgramming ->
            "Logic Programming"

        ProgrammingParadigm__ObjectOrientedProgramming ->
            "Object-Oriented Programming"

        ProgrammingParadigm__ProceduralProgramming ->
            "Procedural Programming"


programmingParadigmFromString : String -> Maybe ProgrammingParadigm
programmingParadigmFromString value =
    case value of
        "Functional Programming" ->
            Just ProgrammingParadigm__FunctionalProgramming

        "Logic Programming" ->
            Just ProgrammingParadigm__LogicProgramming

        "Object-Oriented Programming" ->
            Just ProgrammingParadigm__ObjectOrientedProgramming

        "Procedural Programming" ->
            Just ProgrammingParadigm__ProceduralProgramming

        _ ->
            Nothing


programmingParadigmVariants : List ProgrammingParadigm
programmingParadigmVariants =
    [ ProgrammingParadigm__FunctionalProgramming
    , ProgrammingParadigm__LogicProgramming
    , ProgrammingParadigm__ObjectOrientedProgramming
    , ProgrammingParadigm__ProceduralProgramming
    ]


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

  - description: A brief description of the language, tool, etc being described by this metadata.
  - domains: The domain(s) that the entity is commonly used in, or best suited for.
  - emoji: A Unicode emoji glyph to represent the entity, if applicable. If there is no suitable (Unicode) emoji, omit this field. Consumers may choose to ignore this field, or replace it with a custom image.
  - name: The name of the language, tool, etc being described by this metadata.

-}
type alias Meta =
    { category : ResourceCategory
    , description : String
    , domains : List LanguageDomain
    , emoji : Maybe String
    , name : String
    }


{-| A domain that a programming language may be used in.
-}
type LanguageDomain
    = LanguageDomain__DataScience
    | LanguageDomain__DevOps
    | LanguageDomain__GameDevelopment
    | LanguageDomain__GeneralPurpose
    | LanguageDomain__MobileDevelopment
    | LanguageDomain__Scripting
    | LanguageDomain__SystemsProgramming
    | LanguageDomain__WebDevelopment


languageDomainToString : LanguageDomain -> String
languageDomainToString value =
    case value of
        LanguageDomain__DataScience ->
            "Data Science"

        LanguageDomain__DevOps ->
            "DevOps"

        LanguageDomain__GameDevelopment ->
            "Game Development"

        LanguageDomain__GeneralPurpose ->
            "General Purpose"

        LanguageDomain__MobileDevelopment ->
            "Mobile Development"

        LanguageDomain__Scripting ->
            "Scripting"

        LanguageDomain__SystemsProgramming ->
            "Systems Programming"

        LanguageDomain__WebDevelopment ->
            "Web Development"


languageDomainFromString : String -> Maybe LanguageDomain
languageDomainFromString value =
    case value of
        "Data Science" ->
            Just LanguageDomain__DataScience

        "DevOps" ->
            Just LanguageDomain__DevOps

        "Game Development" ->
            Just LanguageDomain__GameDevelopment

        "General Purpose" ->
            Just LanguageDomain__GeneralPurpose

        "Mobile Development" ->
            Just LanguageDomain__MobileDevelopment

        "Scripting" ->
            Just LanguageDomain__Scripting

        "Systems Programming" ->
            Just LanguageDomain__SystemsProgramming

        "Web Development" ->
            Just LanguageDomain__WebDevelopment

        _ ->
            Nothing


languageDomainVariants : List LanguageDomain
languageDomainVariants =
    [ LanguageDomain__DataScience
    , LanguageDomain__DevOps
    , LanguageDomain__GameDevelopment
    , LanguageDomain__GeneralPurpose
    , LanguageDomain__MobileDevelopment
    , LanguageDomain__Scripting
    , LanguageDomain__SystemsProgramming
    , LanguageDomain__WebDevelopment
    ]


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
  - resources: List of all learning resources

-}
type alias Database =
    { metadata : List CompiledMeta, resources : List Resource }


{-| Fields:

  - description: A brief description of the language, tool, etc being described by this metadata.
  - domains: The domain(s) that the entity is commonly used in, or best suited for.
  - emoji: A Unicode emoji glyph to represent the entity, if applicable. If there is no suitable (Unicode) emoji, omit this field. Consumers may choose to ignore this field, or replace it with a custom image.
  - name: The name of the language, tool, etc being described by this metadata.

-}
type alias CompiledMeta =
    { category : ResourceCategory
    , description : String
    , domains : List LanguageDomain
    , emoji : Maybe String
    , id : EntityTag
    , name : String
    }


type alias CategoryTool =
    { type_ : String }


{-| A platform used to learn programming, which may teach a variety of languages and concepts.
-}
type alias CategoryPlatform =
    { type_ : String }


{-| Fields:

  - paradigms: The programming paradigms that this language focuses on, e.g. 'Object-Oriented Programming', 'Functional Programming', 'Procedural Programming', etc.

-}
type alias CategoryLanguage =
    { paradigms : List ProgrammingParadigm, type_ : String }


type CategoryLanguage_Or_CategoryPlatform_Or_CategoryTool
    = CategoryLanguage_Or_CategoryPlatform_Or_CategoryTool__CategoryLanguage CategoryLanguage
    | CategoryLanguage_Or_CategoryPlatform_Or_CategoryTool__CategoryPlatform CategoryPlatform
    | CategoryLanguage_Or_CategoryPlatform_Or_CategoryTool__CategoryTool CategoryTool


type FreePricing_Or_PaidPricing
    = FreePricing_Or_PaidPricing__FreePricing FreePricing
    | FreePricing_Or_PaidPricing__PaidPricing PaidPricing
