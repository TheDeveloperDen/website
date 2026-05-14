module Pages.Learning.Resource_ exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html.Styled as Html exposing (Html, div, span, text)
import Html.Styled.Attributes as Attr exposing (css, href, target)
import Layouts
import LearningResources.Types as LearningResources
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
import Shared.Model as SharedModel
import Tailwind.Breakpoints as Breakpoints
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw
import Theming
import Css
import View exposing (View)
import LearningResources.Emojis as Emojis


page : Shared.Model -> Route { resource : String } -> Page Model Msg
page shared route =
    Page.new
        { init = \_ -> ( {}, Effect.none )
        , update = \_ model -> ( model, Effect.none )
        , subscriptions = \_ -> Sub.none
        , view = view shared route.params
        }
        |> Page.withLayout (\_ -> Layouts.Global {})


type alias Model =
    {}


type Msg
    = NoOp



-- VIEW


view : Shared.Model -> { resource : String } -> Model -> View Msg
view shared route _ =
    case shared.learningDatabase of
        SharedModel.Loading ->
            { title = "Loading...", body = [ text "Loading resources..." ] }

        SharedModel.Failure _ ->
            { title = "Error", body = [ text "Failed to load database." ] }

        SharedModel.Success db ->
            let
                activeTag =
                    LearningResources.entityTagFromString route.resource

                activeMeta =
                    activeTag 
                        |> Maybe.andThen (\tag -> List.filter (\m -> m.id == tag) db.metadata |> List.head)
            in
            { title = Maybe.map .name activeMeta |> Maybe.withDefault "Topic"
            , body =
                [ viewExplorerLayout db activeTag route.resource ]
            }


viewExplorerLayout : LearningResources.Database -> Maybe LearningResources.EntityTag -> String -> Html Msg
viewExplorerLayout db activeTag activeSlug =
    div [ css [ Tw.flex, Tw.max_w_7xl, Tw.mx_auto, Tw.pt_12, Tw.pb_24, Tw.gap_12 ] ]
        [ 
          div [ css [ Tw.w_64, Tw.flex_shrink_0, Tw.hidden, Breakpoints.lg [ Tw.block ] ] ]
            [ Html.h3 [ css [ Theming.headingFont, Tw.text_xl, Tw.mb_6, Tw.border_b, Tw.border_color Tw.slate_700, Tw.pb_2 ] ] 
                [ text "Topics" ]
            , viewSidebarTopicList db.metadata activeSlug
            ]
            
         
        , div [ css [ Tw.flex_1 ] ]
            [ case activeTag of
                Nothing ->
                    div [ css [ Tw.text_color Tw.gray_400 ] ] [ text "Topic not found." ]

                Just tag ->
                    let
                        maybeMeta =
                            List.filter (\m -> m.id == tag) db.metadata |> List.head

                        topicResources =
                            List.filter (\r -> List.member tag r.teaches) db.resources
                    in
                    div []
                        [ viewTopicHeader maybeMeta
                        , viewResourceGrid topicResources
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
        [ Route.Path.href (Route.Path.Learning_Resource_ { resource = metaSlug }) |> Attr.fromUnstyled
        , css
            [ Theming.headingFont
            , Tw.text_sm
            , Tw.py_2
            , Tw.px_3
            , Tw.rounded_lg
            , Tw.transition_colors
            , if isActive then Tw.bg_color Tw.slate_800 else Tw.bg_color Tw.transparent
            , if isActive then Tw.text_color Tw.white else Tw.text_color Tw.gray_400
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
        [ 
          div [ css [ Tw.flex, Tw.justify_between, Tw.items_start, Tw.mb_4 ] ]
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