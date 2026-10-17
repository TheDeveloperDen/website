module Route.Learning.Resource_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Css
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html.Styled as Html exposing (Html, div, span, text)
import Html.Styled.Attributes as Attr exposing (css)
import LearningResources as Db
import LearningResources.Emojis as Emojis
import LearningResources.Types as LearningResources
import Pages.Url
import PagesMsg exposing (PagesMsg)
import Route
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Tailwind.Breakpoints as Breakpoints
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw
import Theming
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
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "Developer Den"
        , image =
            { url = UrlPath.fromString "devden-banner.svg" |> Pages.Url.fromPath
            , alt = "Developer Den"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = app.data.meta.description
        , locale = Nothing
        , title = "Learn " ++ app.data.meta.name
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    View.fromStyled app.data.meta.name [ viewExplorerLayout app.data app.routeParams.resource ]
        |> View.map PagesMsg.fromMsg


viewExplorerLayout : Data -> String -> Html Msg
viewExplorerLayout topic activeSlug =
    div [ css [ Tw.flex, Tw.max_w_7xl, Tw.mx_auto, Tw.pt_12, Tw.pb_24, Tw.gap_12 ] ]
        [ div [ css [ Tw.w_64, Tw.flex_shrink_0, Tw.hidden, Breakpoints.lg [ Tw.block ] ] ]
            [ Html.h3 [ css [ Theming.headingFont, Tw.text_xl, Tw.mb_6, Tw.border_b, Tw.border_color Tw.slate_700, Tw.pb_2 ] ]
                [ text "Topics" ]
            , viewSidebarTopicList topic.allMetadata activeSlug
            ]
        , div [ css [ Tw.flex_1 ] ]
            [ div []
                [ viewTopicHeader (Just topic.meta)
                , viewResourceGrid topic.resources
                ]
            ]
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
            , Tw.text_sm
            , Tw.py_2
            , Tw.px_3
            , Tw.rounded_lg
            , Tw.transition_colors
            , if isActive then
                Tw.bg_color Tw.slate_800

              else
                Tw.bg_color Tw.transparent
            , if isActive then
                Tw.text_color Tw.white

              else
                Tw.text_color Tw.gray_400
            , Css.hover [ Tw.text_color Tw.white, Tw.bg_color Tw.slate_800 ]
            ]
        ]
        [ text (Emojis.emojiOrBackup meta ++ " " ++ meta.name) ]


viewTopicHeader : Maybe LearningResources.CompiledMeta -> Html Msg
viewTopicHeader maybeMeta =
    case maybeMeta of
        Nothing ->
            text ""

        Just meta ->
            div [ css [ Tw.mb_12, Tw.border_b, Tw.border_color Tw.slate_700, Tw.pb_8 ] ]
                [ div [ css [ Tw.flex, Tw.items_center, Tw.gap_4, Tw.mb_4 ] ]
                    [ div [ css [ Tw.text_5xl ] ] [ text (Emojis.emojiOrBackup meta) ]
                    , Html.h1 [ css [ Theming.headingFont, Tw.text_4xl, Tw.font_bold ] ] [ text meta.name ]
                    ]
                , Html.p [ css [ Theming.bodyFont, Tw.text_xl, Tw.text_color Tw.gray_300, Tw.mb_4 ] ]
                    [ text meta.description ]
                ]


viewResourceGrid : List LearningResources.Resource -> Html Msg
viewResourceGrid resources =
    if List.isEmpty resources then
        div [ css [ Theming.bodyFont, Tw.text_color Tw.gray_400, Tw.italic ] ] [ text "No resources found for this topic yet." ]

    else
        div [ css [ Tw.grid, Tw.grid_cols_1, Breakpoints.md [ Tw.grid_cols_2 ], Tw.gap_6 ] ]
            (List.map viewResourceCard resources)


viewResourceCard : LearningResources.Resource -> Html Msg
viewResourceCard resource =
    Theming.cardShell [ Tw.p_6, Tw.flex, Tw.flex_col ]
        [ div [ css [ Tw.flex, Tw.justify_between, Tw.items_start, Tw.mb_4 ] ]
            [ Html.h3 [ css [ Theming.headingFont, Tw.text_lg ] ] [ text resource.name ]
            , viewPricingBadge resource.pricing
            ]
        , div [ css [ Tw.flex, Tw.gap_2, Tw.mb_4 ] ]
            (List.map viewTypeBadge resource.type_)
        , Html.p [ css [ Theming.bodyFont, Tw.text_sm, Tw.mb_6, Tw.flex_grow ] ]
            [ text (Maybe.withDefault "No description provided." resource.description) ]
        , Html.a
            [ Attr.href resource.url
            , Attr.target "_blank"
            , css
                [ Theming.headingFont
                , Tw.text_color Tw.dd_pink
                , Css.hover [ Tw.text_color Tw.white ]
                , Tw.transition_colors
                ]
            ]
            [ text "Read more ->" ]
        ]


viewTypeBadge : LearningResources.ResourceType -> Html Msg
viewTypeBadge resourceType =
    span
        [ css
            [ Tw.text_xs
            , Tw.font_medium
            , Tw.bg_color Tw.indigo_900
            , Tw.text_color Tw.indigo_200
            , Tw.px_2
            , Tw.py_1
            , Tw.rounded_md
            ]
        ]
        [ text (LearningResources.resourceTypeToString resourceType) ]


viewPricingBadge : LearningResources.Pricing -> Html Msg
viewPricingBadge pricing =
    case pricing of
        LearningResources.FreePricing_Or_PaidPricing__FreePricing free ->
            span
                [ css
                    [ Tw.text_xs
                    , Tw.font_bold
                    , Tw.bg_color Tw.emerald_900
                    , Tw.text_color Tw.emerald_400
                    , Tw.px_2
                    , Tw.py_1
                    , Tw.rounded_md
                    ]
                ]
                [ text free.model ]

        LearningResources.FreePricing_Or_PaidPricing__PaidPricing paid ->
            span
                [ css
                    [ Tw.text_xs
                    , Tw.font_bold
                    , Tw.bg_color Tw.slate_700
                    , Tw.text_color Tw.slate_300
                    , Tw.px_2
                    , Tw.py_1
                    , Tw.rounded_md
                    ]
                ]
                [ text (paid.model ++ ": $" ++ String.fromFloat paid.amount) ]
