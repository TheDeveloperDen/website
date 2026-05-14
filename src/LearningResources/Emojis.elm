-- Backup emoji mappings for learning resources


module LearningResources.Emojis exposing (..)

import LearningResources.Types as LearningResources


emojiForTag : LearningResources.EntityTag -> String
emojiForTag tag =
    case tag of
        LearningResources.EntityTag__Clojure ->
            "🍵"

        LearningResources.EntityTag__Python ->
            "🐍"

        LearningResources.EntityTag__Rust ->
            "🦀"

        LearningResources.EntityTag__Haskell ->
            "📐"

        LearningResources.EntityTag__Java ->
            "☕"
        
        LearningResources.EntityTag__Kotlin ->
            "🤖"

        _ ->
            "📚"


emojiOrBackup : LearningResources.CompiledMeta -> String
emojiOrBackup meta =
    case meta.emoji of
        Just e ->
            case String.length e of
                1 ->
                    e

                2 ->
                    e

                _ ->
                    emojiForTag meta.id

        Nothing ->
            emojiForTag meta.id
