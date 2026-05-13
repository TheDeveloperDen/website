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
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw
import View exposing (View)


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
            case LearningResources.entityTagFromString route.resource of
                Nothing ->
                    { title = "Not Found", body = [ text "Topic not found." ] }

                Just tag ->
                    let
                        maybeMeta =
                            List.filter (\m -> m.id == tag) db.metadata |> List.head

                        topicResources =
                            List.filter (\r -> List.member tag r.teaches) db.resources
                    in
                    { title = Maybe.map .name maybeMeta |> Maybe.withDefault "Topic"
                    , body =
                        [ div [ css [ Tw.max_w_5xl, Tw.mx_auto, Tw.py_12 ] ]
                            [ viewTopicHeader maybeMeta
                            , viewResourceGrid topicResources
                            ]
                        ]
                    }


viewTopicHeader : Maybe LearningResources.CompiledMeta -> Html Msg
viewTopicHeader maybeMeta =
    case maybeMeta of
        Nothing ->
            text ""

        Just meta ->
            div [ css [ Tw.mb_12, Tw.border_b, Tw.border_color Tw.slate_700, Tw.pb_8 ] ]
                [ div [ css [ Tw.flex, Tw.items_center, Tw.gap_4, Tw.mb_4 ] ]
                    [ div [ css [ Tw.text_5xl ] ] [ text (Maybe.withDefault "" meta.emoji) ]
                    , Html.h1 [ css [ Tw.text_4xl, Tw.font_bold ] ] [ text meta.name ]
                    ]
                , Html.p [ css [ Tw.text_xl, Tw.text_color Tw.gray_300, Tw.mb_4 ] ] [ text meta.description ]
                ]


viewResourceGrid : List LearningResources.Resource -> Html Msg
viewResourceGrid resources =
    if List.isEmpty resources then
        div [ css [ Tw.text_color Tw.gray_400, Tw.italic ] ] [ text "No resources found for this topic yet." ]

    else
        div [ css [ Tw.grid, Tw.grid_cols_1, Tw.gap_6 ] ]
            (List.map viewResourceCard resources)


viewResourceCard : LearningResources.Resource -> Html Msg
viewResourceCard resource =
    div
        [ css
            [ Tw.bg_color Tw.slate_800
            , Tw.rounded_xl
            , Tw.p_6
            , Tw.border
            , Tw.border_color Tw.slate_700
            , Tw.flex
            , Tw.flex_col
            ]
        ]
        [ div [ css [ Tw.flex, Tw.justify_between, Tw.items_start, Tw.mb_2 ] ]
            [ Html.h3 [ css [ Tw.font_bold, Tw.text_lg, Tw.text_color Tw.white ] ] [ text resource.name ]
            , viewPricingBadge resource.pricing
            ]
        , div [ css [ Tw.flex, Tw.gap_2, Tw.mb_4 ] ]
            (List.map viewTypeBadge resource.type_)
        , Html.p [ css [ Tw.text_sm, Tw.text_color Tw.gray_400, Tw.flex_grow, Tw.mb_6 ] ]
            [ text (Maybe.withDefault "No description available." resource.description) ]
        , Html.a
            [ href resource.url
            , target "_blank"
            , css
                [ Tw.inline_block
                , Tw.text_center
                , Tw.bg_color Tw.fuchsia_600
                , Tw.text_color Tw.white
                , Tw.font_bold
                , Tw.py_2
                , Tw.px_4
                , Tw.rounded_lg
                , Tw.transition_colors
                ]
            ]
            [ text "Go to Resource" ]
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