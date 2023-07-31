module Views.LearningResources exposing (..)

import Data.LearningResources exposing (LearningResources, learningResourcesDecoder)
import Dict exposing (Dict)
import Html exposing (Html, text, ul)
import Http
import Json.Decode as Decode exposing (Decoder)
import Redirects exposing (learningResourcesUrl)
import Tailwind as Tw


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
        { url = Debug.log "lr" learningResourcesUrl
        , expect = Http.expectJson ResourceIndexLoaded (Decode.list decodeResourceIndex)
        }


getResource : String -> Cmd Msg
getResource name =
    Http.get
        { url = learningResourcesUrl ++ "/" ++ name
        , expect = Http.expectJson (ResourceLoaded name) learningResourcesDecoder
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

        ( ResourceLoaded name (Ok resource), Loaded { resourceNames, resources, selectedResource } ) ->
            ( Loaded { resourceNames = resourceNames, resources = Dict.insert resource.name resource resources, selectedResource = Just ( name, resource ) }, Cmd.none )

        ( ResourceLoaded name (Err e), Loaded { resourceNames, resources, selectedResource } ) ->
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
                Html.text ("Failed to load resource " ++ name)

            LoadedIndex index ->
                viewIndexSidebar index

            Loaded { resourceNames, resources, selectedResource } ->
                Html.text <| Debug.toString ( resourceNames, resources, selectedResource )
    }


viewIndexSidebar : List String -> Html Msg
viewIndexSidebar resourceNames =
    let
        createLi name =
            Html.li []
                [ Html.a [ Tw.flex, Tw.items_center, Tw.p_2, Tw.text_base, Tw.font_normal, Tw.text_gray_900, Tw.rounded_lg, Tw.hover__bg_gray_700 ]
                    [ Html.span [ Tw.flex_1, Tw.ml_3, Tw.whitespace_nowrap ] [ text (prettifyResourceName name) ]
                    ]
                ]
    in
    Html.div [ Tw.fixed ]
        [ ul [] (List.map createLi resourceNames)
        ]


prettifyResourceName : String -> String
prettifyResourceName name =
    String.join " " (String.split "-" name)
        |> String.replace ".json" ""
        |> String.replace ".yaml" " "
