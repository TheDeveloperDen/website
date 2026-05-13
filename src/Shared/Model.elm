module Shared.Model exposing
    ( LearningDatabaseStatus(..)
    , Model
    )

{-| -}

import Dict exposing (Dict)
import Http
import LearningResources.Types as LearningResources


{-| Normally, this value would live in "Shared.elm"
but that would lead to a circular dependency import cycle.

For that reason, both `Shared.Model` and `Shared.Msg` are in their
own file, so they can be imported by `Effect.elm`

-}
type LearningDatabaseStatus
    = Loading
    | Success LearningResources.Database
    | Failure Http.Error



type alias Model =
    { learningDatabase : LearningDatabaseStatus
    }
