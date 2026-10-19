module Route.Learning.Resource_ exposing (ActionData, Data, Model, Msg, RouteParams, route)

import BackendTask exposing (BackendTask)
import Banner
import Css
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html.Styled as Html exposing (Html, div, span, text)
import Html.Styled.Attributes as Attr exposing (css)
import Json.Encode
import LearningResources as Db
import LearningResources.Types as LearningResources
import PagesMsg exposing (PagesMsg)
import Route
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Tailwind.Breakpoints as Breakpoints
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw
import Theming
import Url
import UrlPath
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    { resource : String }


type alias Data =
    { allMetadata : List LearningResources.CompiledMeta
    , meta : LearningResources.CompiledMeta
    , resources : List LearningResources.Resource
    }


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.preRender
        { head = head
        , pages = pages
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


pages : BackendTask FatalError (List RouteParams)
pages =
    Db.fetchDatabase
        |> BackendTask.map
            (\db ->
                List.map (\meta -> { resource = LearningResources.entityTagToString meta.id }) db.metadata
            )


data : RouteParams -> BackendTask FatalError Data
data params =
    Db.fetchDatabase
        |> BackendTask.andThen
            (\db ->
                case LearningResources.entityTagFromString params.resource |> Maybe.andThen (\tag -> Db.getMetadata tag db |> Maybe.map (Tuple.pair tag)) of
                    Just ( tag, meta ) ->
                        BackendTask.succeed
                            { allMetadata = db.metadata
                            , meta = meta
                            , resources = Db.getResourcesByTag tag db
                            }

                    Nothing ->
                        BackendTask.fail (FatalError.fromString ("Unknown learning topic: " ++ params.resource))
            )


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    Head.structuredData (itemList app.data)
        :: (Seo.summaryLarge
                { canonicalUrlOverride = Nothing
                , siteName = "Developer Den"
                , image = Banner.seoImage (LearningResources.entityTagToString app.data.meta.id) ("Learn " ++ app.data.meta.name ++ " on Developer Den")
                , description = app.data.meta.description
                , locale = Nothing
                , title = pageTitle app.data.meta.name ++ " | Developer Den"
                }
                |> Seo.website
           )


pageTitle : String -> String
pageTitle name =
    "Learn " ++ name ++ ": free and paid resources"


{-| schema.org `CollectionPage` listing the topic's resources, for search engine rich results.
-}
itemList : Data -> Json.Encode.Value
itemList topic =
    Json.Encode.object
        [ ( "@context", Json.Encode.string "https://schema.org" )
        , ( "@type", Json.Encode.string "CollectionPage" )
        , ( "name", Json.Encode.string (pageTitle topic.meta.name) )
        , ( "description", Json.Encode.string topic.meta.description )
        , ( "mainEntity"
          , Json.Encode.object
                [ ( "@type", Json.Encode.string "ItemList" )
                , ( "itemListElement"
                  , Json.Encode.list
                        (\( position, resource ) ->
                            Json.Encode.object
                                [ ( "@type", Json.Encode.string "ListItem" )
                                , ( "position", Json.Encode.int position )
                                , ( "name", Json.Encode.string resource.name )
                                , ( "url", Json.Encode.string (Url.toString resource.url) )
                                ]
                        )
                        (List.indexedMap (\i r -> ( i + 1, r )) topic.resources)
                  )
                ]
          )
        ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    View.fromStyled (pageTitle app.data.meta.name) [ viewExplorerLayout app.data app.routeParams.resource ]
        |> View.map PagesMsg.fromMsg


viewExplorerLayout : Data -> String -> Html Msg
viewExplorerLayout topic activeSlug =
    div [ css [ Tw.flex, Tw.max_w_7xl, Tw.mx_auto, Theming.gutter, Tw.pt_12, Tw.pb_24, Tw.gap_12 ] ]
        [ div [ css [ Tw.w_64, Tw.flex_shrink_0, Tw.hidden, Breakpoints.lg [ Tw.block ] ] ]
            [ Html.h3 [ css [ Theming.headingFont, Tw.text_xl, Tw.mb_6, Tw.border_b, Tw.border_color Tw.dd_border, Tw.pb_2, Tw.lowercase ] ]
                [ text "Topics" ]
            , viewSidebarTopicList topic.allMetadata activeSlug
            ]
        , div [ css [ Tw.flex_1, Tw.min_w_0 ] ]
            [ viewMobileTopics topic.allMetadata activeSlug
            , viewTopicHeader (Just topic.meta)
            , viewResourceGrid topic.resources
            ]
        ]


{-| The sidebar only fits on wide screens, so we use a details section instead on mobile
-}
viewMobileTopics : List LearningResources.CompiledMeta -> String -> Html Msg
viewMobileTopics metadata activeSlug =
    Html.details
        [ css
            [ Breakpoints.lg [ Tw.hidden ]
            , Tw.mb_8
            , Tw.border
            , Tw.border_color Tw.dd_border
            ]
        ]
        [ Html.summary [ css [ Theming.headingFont, Tw.p_4, Tw.cursor_pointer ] ] [ text "all topics" ]
        , div [ css [ Tw.p_2 ] ] [ viewSidebarTopicList metadata activeSlug ]
        ]


viewSidebarTopicList : List LearningResources.CompiledMeta -> String -> Html Msg
viewSidebarTopicList metadata activeSlug =
    div [ css [ Tw.flex, Tw.flex_col, Tw.gap_2 ] ]
        (List.map (viewSidebarLink activeSlug) metadata)


viewSidebarLink : String -> LearningResources.CompiledMeta -> Html Msg
viewSidebarLink activeSlug meta =
    let
        metaSlug =
            LearningResources.entityTagToString meta.id

        isActive =
            activeSlug == metaSlug
    in
    Html.a
        [ Attr.href (UrlPath.toAbsolute (Route.toPath (Route.Learning__Resource_ { resource = metaSlug })))
        , css
            [ Theming.headingFont
            , Tw.flex
            , Tw.items_center
            , Tw.gap_2
            , Tw.text_sm
            , Tw.no_underline
            , Tw.py_2
            , Tw.px_3
            , Tw.border_l_2
            , Tw.transition_colors
            , if isActive then
                Tw.border_color Tw.dd_teal

              else
                Tw.border_color Tw.transparent
            , if isActive then
                Tw.bg_color Tw.dd_deepblueLighter

              else
                Tw.bg_color Tw.transparent
            , if isActive then
                Tw.text_color Tw.dd_text

              else
                Tw.text_color Tw.dd_subtle
            , Css.hover [ Tw.text_color Tw.dd_text, Tw.bg_color Tw.dd_deepblueLighter ]
            ]
        ]
        [ Theming.entityIcon (Css.batch [ Tw.w_5, Tw.h_5 ]) meta, text meta.name ]


viewTopicHeader : Maybe LearningResources.CompiledMeta -> Html Msg
viewTopicHeader maybeMeta =
    case maybeMeta of
        Nothing ->
            text ""

        Just meta ->
            div [ css [ Tw.mb_12, Tw.border_b, Tw.border_color Tw.dd_border, Tw.pb_8 ] ]
                [ div [ css [ Tw.flex, Tw.items_center, Tw.gap_4, Tw.mb_6 ] ]
                    [ Theming.entityIcon (Css.batch [ Tw.w_14, Tw.h_14, Tw.text_5xl ]) meta
                    , Theming.pageTitle meta.name
                    ]
                , Html.p [ css [ Theming.bodyFont, Tw.text_xl, Tw.m_0, Tw.mb_4 ] ]
                    [ text meta.description ]
                ]


viewResourceGrid : List LearningResources.Resource -> Html Msg
viewResourceGrid resources =
    if List.isEmpty resources then
        div [ css [ Theming.bodyFont, Tw.italic ] ] [ text "No resources found for this topic yet." ]

    else
        div [ css [ Tw.grid, Tw.grid_cols_1, Breakpoints.md [ Tw.grid_cols_2 ], Tw.gap_6 ] ]
            (List.map viewResourceCard resources)


viewResourceCard : LearningResources.Resource -> Html Msg
viewResourceCard resource =
    Theming.cardShell [ Tw.p_6, Tw.flex, Tw.flex_col, Tw.transition_colors, Css.hover [ Tw.border_color Tw.dd_indigo ] ]
        [ div [ css [ Tw.flex, Tw.justify_between, Tw.items_start, Tw.mb_4 ] ]
            [ Html.h3 [ css [ Theming.headingFont, Tw.text_lg ] ] [ text resource.name ]
            , viewPricingBadge resource.pricing
            ]
        , div [ css [ Tw.flex, Tw.gap_2, Tw.mb_4 ] ]
            (List.map viewTypeBadge resource.type_)
        , Html.p [ css [ Theming.bodyFont, Tw.text_sm, Tw.mb_6, Tw.flex_grow ] ]
            [ text (Maybe.withDefault "No description provided." resource.description) ]
        , Html.a
            [ Attr.href (Url.toString resource.url)
            , Attr.target "_blank"
            , css
                [ Theming.headingFont
                , Tw.text_color Tw.dd_indigo
                , Css.hover [ Tw.text_color Tw.dd_pink ]
                , Tw.transition_colors
                , Tw.no_underline
                ]
            ]
            [ text "view resource" ]
        ]


viewTypeBadge : LearningResources.ResourceType -> Html Msg
viewTypeBadge resourceType =
    viewTag Tw.font_medium Theming.Indigo (LearningResources.resourceTypeToString resourceType)


viewPricingBadge : LearningResources.Pricing -> Html Msg
viewPricingBadge pricing =
    case pricing of
        LearningResources.FreePricing_Or_PaidPricing__FreePricing free ->
            viewTag Tw.font_bold Theming.Teal free.model

        LearningResources.FreePricing_Or_PaidPricing__PaidPricing paid ->
            viewTag Tw.font_bold Theming.Pink (paid.model ++ ": $" ++ String.fromFloat paid.amount)


viewTag : Css.Style -> Theming.Accent -> String -> Html Msg
viewTag weight accent label =
    span
        [ css [ Tw.text_xs, weight, Theming.badgeStyle accent, Tw.px_2, Tw.py_1 ] ]
        [ text label ]
