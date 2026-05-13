module LearningResources exposing (..)

import LearningResources.Types exposing (..)

getResourcesByTag : EntityTag -> Database -> List Resource
getResourcesByTag tag database =
    List.filter (\resource -> List.member tag resource.teaches) database.resources

getMetadata : EntityTag -> Database -> Maybe CompiledMeta
getMetadata tag database =
    List.head <| List.filter (\meta -> meta.id == tag) database.metadata