module Shared.Model exposing (LearningIndexStatus(..), Model)

{-| -}

import Http
import LearningResources


{-| Normally, this value would live in "Shared.elm"
but that would lead to a circular dependency import cycle.

For that reason, both `Shared.Model` and `Shared.Msg` are in their
own file, so they can be imported by `Effect.elm`

-}
type LearningIndexStatus
    = Loading
    | Success (List LearningResources.ResourceIndexEntry)
    | Failure Http.Error


type alias Model =
    { learningIndex : LearningIndexStatus
    }
