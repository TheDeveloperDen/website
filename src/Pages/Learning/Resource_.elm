module Pages.Learning.Resource_ exposing (Model, Msg, page)

import Api
import Dict
import Effect exposing (Effect, sendSharedMsg)
import Html.Styled as Html
import Http
import LearningResources
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Shared.Model as SharedModel
import Shared.Msg
import View exposing (View)


page : Shared.Model -> Route { resource : String } -> Page Model Msg
page shared route =
    Page.new
        { init = \() -> init shared route.params
        , update = update
        , subscriptions = subscriptions
        , view = view shared route.params
        }



-- INIT


type alias Model =
    { resourceInfo : ResourceInfo, resourceId : String }


type ResourceInfo
    = NotFound
    | Loading
    | Found LearningResources.LearningResourcesSet


init : Shared.Model -> { resource : String } -> ( Model, Effect Msg )
init model route =
    case Dict.get route.resource model.learningResources of
        Nothing ->
            ( { resourceInfo = Loading, resourceId = route.resource }
            , Api.getLearningResource { name = route.resource, onResponse = LearningResourceResponded }
            )

        Just info ->
            ( { resourceInfo = sharedResourceInfoToResourceInfo info, resourceId = route.resource }
            , Effect.none
            )


sharedResourceInfoToResourceInfo : SharedModel.ResourceInfo -> ResourceInfo
sharedResourceInfoToResourceInfo model =
    case model of
        SharedModel.NotFound ->
            NotFound

        SharedModel.Found resourcesSet ->
            Found resourcesSet



-- UPDATE


type Msg
    = LearningResourceResponded (Result Http.Error LearningResources.LearningResourcesSet)


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        LearningResourceResponded (Ok resourcesSet) ->
            ( { model | resourceInfo = Found resourcesSet }
            , Effect.sendSharedMsg (Shared.Msg.CacheLearningResource ( model.resourceId, resourcesSet ))
            )

        LearningResourceResponded (Err _) ->
            ( { model | resourceInfo = NotFound }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Shared.Model -> { resource : String } -> Model -> View Msg
view shared route model =
    case model.resourceInfo of
        Loading ->
            { title = "Loading resource..."
            , body =
                [ Html.text "Loading learning resource..." ]
            }

        NotFound ->
            { title = "Resource not found"
            , body =
                [ Html.text "The requested learning resource could not be found." ]
            }

        Found resourcesSet ->
            { title = "pee"
            , body =
                [ Html.div []
                    [ Html.text resourcesSet.name
                    , Html.text resourcesSet.description
                    ]
                ]
            }
