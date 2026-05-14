-- Backup emoji mappings for learning resources


module LearningResources.Emojis exposing (..)

import LearningResources.Types as LearningResources exposing (EntityTag(..))


emojiForTag : EntityTag -> String
emojiForTag tag =
    case tag of
        EntityTag__Clojure ->
            "🍵"

        EntityTag__Python ->
            "🐍"

        EntityTag__Rust ->
            "🦀"

        EntityTag__Haskell ->
            "📐"

        EntityTag__Java ->
            "☕"

        EntityTag__Kotlin ->
            "🤖"

        EntityTag__Cpp ->
            "💻"

        EntityTag__Sql ->
            "🗄️"

        EntityTag__Php ->
            "🐘"

        EntityTag__ProgrammingLanguageDesign ->
            "🛠️"

        EntityTag__Git ->
            "🔧"

        EntityTag__General ->
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
