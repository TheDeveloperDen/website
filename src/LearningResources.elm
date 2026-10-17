module LearningResources exposing (fetchDatabase, getMetadata, getResourcesByTag)

import BackendTask exposing (BackendTask)
import BackendTask.Http
import FatalError exposing (FatalError)
import LearningResources.Json as Json
import LearningResources.Types exposing (CompiledMeta, Database, EntityTag, Resource)


databaseUrl : String
databaseUrl =
    "https://cdn.jsdelivr.net/gh/TheDeveloperDen/LearningResources@master/database.json"


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
