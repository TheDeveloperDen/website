module Views.LearningResources exposing (..)

import Data.LearningResources exposing (LearningResources, Resource, learningResourcesDecoder)
import Dict exposing (Dict)
import Html exposing (Html, text, ul)
import Http
import Json.Decode as Decode exposing (Decoder)
import Redirects exposing (learningResourcesUrl)
import Route
import Tailwind as Tw
import Util exposing (expectYaml)


type Model
    = IndexFail Http.Error
    | LoadResourceFail String Http.Error
    | LoadedIndex (List String)
    | Loaded
        { resourceNames : List String
        , resources : Dict String LearningResources
        , selectedResource : Maybe ( String, LearningResources )
        }


type Msg
    = LoadResources
    | ResourceIndexLoaded (Result Http.Error (List String))
    | LoadResource String
    | ResourceLoaded String (Result Http.Error LearningResources)


decodeResourceIndex : Decoder String
decodeResourceIndex =
    Decode.field "name" Decode.string


getResourceIndex : Cmd Msg
getResourceIndex =
    Http.get
        { url = learningResourcesUrl
        , expect = Http.expectJson ResourceIndexLoaded (Decode.list decodeResourceIndex)
        }


getResource : String -> Cmd Msg
getResource name =
    Http.get
        { url = learningResourcesUrl ++ "/" ++ name
        , expect = expectYaml (ResourceLoaded name) learningResourcesDecoder
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( LoadResources, _ ) ->
            ( model, getResourceIndex )

        ( ResourceIndexLoaded (Ok index), _ ) ->
            ( LoadedIndex index, Cmd.none )

        ( ResourceIndexLoaded (Err e), _ ) ->
            ( IndexFail e, Cmd.none )

        ( LoadResource name, _ ) ->
            ( model, getResource name )

        ( ResourceLoaded name (Ok resource), Loaded { resourceNames, resources } ) ->
            Debug.log "ResourceLoaded"
                ( Loaded
                    { resourceNames = resourceNames
                    , resources = Dict.insert resource.name resource resources
                    , selectedResource = Just ( name, resource )
                    }
                , Cmd.none
                )

        ( ResourceLoaded name (Ok resource), LoadedIndex idx ) ->
            ( Loaded
                { resourceNames = idx
                , resources = Dict.singleton resource.name resource
                , selectedResource = Just ( name, resource )
                }
            , Cmd.none
            )

        ( ResourceLoaded name (Err e), _ ) ->
            ( LoadResourceFail name e, Cmd.none )

        _ ->
            ( model, Cmd.none )


init : Maybe String -> ( Model, Cmd Msg )
init mRes =
    case mRes of
        Just res ->
            ( Loaded { resourceNames = [], resources = Dict.empty, selectedResource = Nothing }, Cmd.batch [ getResourceIndex, getResource res ] )

        Nothing ->
            ( Loaded { resourceNames = [], resources = Dict.empty, selectedResource = Nothing }, getResourceIndex )


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Learning Resources"
    , content =
        case model of
            IndexFail e ->
                Html.text "Failed to load index"

            LoadResourceFail name e ->
                Html.text ("Failed to load resource " ++ name ++ ": " ++ Debug.toString e)

            LoadedIndex index ->
                viewIndexSidebar index

            Loaded { resourceNames, resources, selectedResource } ->
                Html.div [ Tw.flex, Tw.flex_row ]
                    [ viewIndexSidebar resourceNames
                    , viewResource resources selectedResource
                    ]
    }


viewIndexSidebar : List String -> Html Msg
viewIndexSidebar resourceNames =
    let
        createLi name =
            Html.li []
                [ Html.a
                    [ Route.href (Route.LearningResources (Just name))
                    , Tw.flex
                    , Tw.items_center
                    , Tw.p_2
                    , Tw.text_base
                    , Tw.font_normal
                    , Tw.text_gray_900
                    , Tw.rounded_lg
                    , Tw.hover__bg_gray_700
                    ]
                    [ Html.span [ Tw.flex_1, Tw.ml_3, Tw.whitespace_nowrap ]
                        [ text (prettifyResourceName name) ]
                    ]
                ]
    in
    -- sidebar with list of resources which appears _under_ the navbar
    Html.div [ Tw.flex, Tw.flex_col, Tw.bg_gray_200, Tw.w_64, Tw.h_auto, Tw.my_auto, Tw.overflow_y_auto ]
        [ Html.h1 [ Tw.text_2xl, Tw.font_montserrat, Tw.text_center, Tw.py_2 ] [ text "Resources" ]
        , ul [] (List.map createLi resourceNames)
        ]


prettifyResourceName : String -> String
prettifyResourceName name =
    String.join " " (String.split "-" name)
        |> String.replace ".json" ""
        |> String.replace ".yaml" " "


viewResource : Dict String LearningResources -> Maybe ( String, LearningResources ) -> Html Msg
viewResource resources selectedResource =
    case selectedResource of
        Just ( name, resource ) ->
            Html.div [ Tw.flex, Tw.flex_col, Tw.ml_64, Tw.mr_64, Tw.mt_20, Tw.text_white ]
                ([ Html.h1 [] [ text resource.name ]
                 , Html.h2 [] [ text resource.description ]
                 ]
                    ++ List.map (viewResourcesSection resource) resource.resources
                )

        Nothing ->
            Html.text "Select a resource to view"


viewResourcesSection : LearningResources -> Resource -> Html Msg
viewResourcesSection resources section =
    Html.div []
        [ Html.h3 [] [ text section.name ]
        , Html.ul [] (List.map (Html.li [] << List.singleton << Html.text) section.pros)
        ]
