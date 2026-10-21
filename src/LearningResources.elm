module LearningResources exposing (fetchDatabase, getMetadata, getResourcesByTag, iconUrl)

import BackendTask exposing (BackendTask)
import BackendTask.Http
import FatalError exposing (FatalError)
import LearningResources.Json as Json
import LearningResources.Types exposing (CompiledMeta, Database, EntityTag, Resource)


repoUrl : String
repoUrl =
    "https://cdn.jsdelivr.net/gh/TheDeveloperDen/LearningResources@94a95ce0bc8c0625e2af95b404d80f2224714b73/"


databaseUrl : String
databaseUrl =
    repoUrl ++ "database.json"


{-| Resolves an icon path from the database (e.g. `icons/rust.svg`) to a URL.
-}
iconUrl : String -> String
iconUrl path =
    repoUrl ++ path


{-| Fetched at build time, so every topic page is pre-rendered.
-}
fetchDatabase : BackendTask FatalError Database
fetchDatabase =
    BackendTask.Http.getJson databaseUrl Json.decodeDatabase
        |> BackendTask.allowFatal


getResourcesByTag : EntityTag -> Database -> List Resource
getResourcesByTag tag database =
    List.filter (\resource -> List.member tag resource.teaches) database.resources


getMetadata : EntityTag -> Database -> Maybe CompiledMeta
getMetadata tag database =
    List.head <| List.filter (\meta -> meta.id == tag) database.metadata
