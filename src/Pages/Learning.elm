module Pages.Learning exposing (Model, Msg, page)

import Css
import Dict
import Effect exposing (Effect)
import Html.Styled as Html exposing (Html, div, span, text)
import Html.Styled.Attributes as Attr exposing (css)
import Html.Styled.Events exposing (onInput)
import Layouts
import LearningResources.Emojis as Emojis
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
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared _ =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view shared
        }
        |> Page.withLayout (\_ -> Layouts.Global { activePage = Route.Path.Learning })



-- INIT & STATE


type alias Model =
    { searchQuery : String }


type Msg
    = SearchQueryChanged String


init : () -> ( Model, Effect Msg )
init _ =
    ( { searchQuery = "" }, Effect.none )


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SearchQueryChanged query ->
            ( { model | searchQuery = query }, Effect.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    { title = "Learning Directory"
    , body =
        [ div [ css [ Tw.pt_12, Tw.pb_24, Tw.max_w_7xl, Tw.mx_auto, Tw.px_6 ] ]
            [ viewHeader model.searchQuery
            , case shared.learningDatabase of
                SharedModel.Loading ->
                    div [ css [ Theming.bodyFont, Tw.text_center, Tw.text_color Tw.gray_400 ] ]
                        [ text "Loading learning directory..." ]

                SharedModel.Failure _ ->
                    div [ css [ Theming.bodyFont, Tw.text_center, Tw.text_color Tw.red_400 ] ]
                        [ text "Failed to load directory." ]

                SharedModel.Success db ->
                    viewCategorisedGrid model.searchQuery db.metadata
            ]
        ]
    }


viewHeader : String -> Html Msg
viewHeader query =
    div [ css [ Tw.flex, Tw.flex_col, Tw.items_center, Tw.text_center, Tw.mb_16 ] ]
        [ Html.h1
            [ css [ Theming.headingFont, Tw.text_5xl, Tw.font_bold, Tw.tracking_widest, Tw.uppercase, Tw.mb_4 ] ]
            [ text "Learning Resources" ]
        , Html.p
            [ css [ Theming.bodyFont, Tw.text_lg, Tw.text_color Tw.gray_400, Tw.max_w_2xl, Tw.mb_8 ] ]
            [ text "Explore our curated directory of programming languages, tools, and concepts." ]
        , Html.input
            [ Attr.value query
            , onInput SearchQueryChanged
            , Attr.placeholder "Search topics or domains (e.g., 'Rust', 'Web')..."
            , css
                [ Theming.bodyFont
                , Tw.w_full
                , Tw.max_w_lg
                , Tw.p_4
                , Tw.rounded_xl
                , Tw.bg_color Tw.slate_800
                , Tw.border
                , Tw.border_color Tw.slate_700
                , Tw.text_color Tw.white
                ]
            ]
            []
        ]


viewCategorisedGrid : String -> List LearningResources.CompiledMeta -> Html Msg
viewCategorisedGrid query metadata =
    let
        q =
            String.toLower query

        filtered =
            List.filter
                (\meta ->
                    String.contains q (String.toLower meta.name)
                        || List.any (\domain -> String.contains q (String.toLower (LearningResources.languageDomainToString domain))) meta.domains
                )
                metadata

        grouped =
            List.foldl
                (\meta acc ->
                    let
                        catStr =
                            categoryToString meta.category
                    in
                    Dict.update catStr
                        (\maybeList -> Just (Maybe.withDefault [] maybeList ++ [ meta ]))
                        acc
                )
                Dict.empty
                filtered
    in
    div [ css [ Tw.flex, Tw.flex_col, Tw.gap_10 ] ]
        (Dict.toList grouped
            |> List.map (\( category, items ) -> viewCategorySection category items)
        )


viewCategorySection : String -> List LearningResources.CompiledMeta -> Html msg
viewCategorySection category items =
    div []
        [ Html.h2
            [ css
                [ Theming.headingFont
                , Tw.text_3xl
                , Tw.font_bold
                , Tw.mb_8
                , Theming.textGradient
                , Tw.inline_block
                ]
            ]
            [ text category ]
        , div
            [ css
                [ Tw.grid
                , Tw.grid_cols_1
                , Breakpoints.md [ Tw.grid_cols_3 ]
                , Breakpoints.lg [ Tw.grid_cols_4 ]
                , Tw.gap_6
                ]
            ]
            (List.map viewTopicCard items)
        ]


viewTopicCard : LearningResources.CompiledMeta -> Html msg
viewTopicCard meta =
    Html.a
        [ Route.Path.href (Route.Path.Learning_Resource_ { resource = LearningResources.entityTagToString meta.id })
            |> Attr.fromUnstyled
        , css
            [ Tw.block
            , Tw.no_underline
            , Tw.cursor_pointer
            ]
        ]
        [ Theming.cardShell
            [ Tw.relative
            , Tw.transform
            , Tw.transition_all
            , Tw.duration_300
            , Css.hover
                [ Tw.border
                , Tw.border_color Tw.dd_pink
                , Tw.neg_translate_y_1
                ]
            ]
            [ div
                [ css
                    [ Tw.absolute
                    , Tw.top_0
                    , Tw.left_0
                    , Tw.right_0
                    , Tw.h_1
                    , Theming.brandGradientBg
                    ]
                ]
                []
            , div [ css [ Tw.p_5, Tw.bg_color Tw.dd_deepblue ] ]
                [ div [ css [ Tw.flex, Tw.items_center, Tw.gap_3, Tw.mb_2 ] ]
                    [ div [ css [ Tw.text_3xl, Tw.drop_shadow_md ] ] [ text (Emojis.emojiOrBackup meta) ]
                    , Html.h3 [ css [ Theming.headingFont, Tw.text_xl, Tw.font_bold ] ] [ text meta.name ]
                    ]
                , Html.p
                    [ css [ Theming.bodyFont, Tw.text_sm, Tw.text_color Tw.gray_300, Tw.mb_4 ] ]
                    [ text meta.description ]
                , div [ css [ Tw.flex, Tw.flex_wrap, Tw.gap_2 ] ]
                    (List.map (LearningResources.languageDomainToString >> viewBadge) meta.domains)
                ]
            ]
        ]


viewBadge : String -> Html msg
viewBadge label =
    span
        [ css
            [ Theming.headingFont
            , Tw.text_xs
            , Tw.font_medium
            , Tw.bg_color Tw.slate_800
            , Tw.text_color Tw.slate_300
            , Tw.border
            , Tw.border_color Tw.slate_600
            , Tw.text_color Tw.slate_300
            , Tw.px_3
            , Tw.py_1
            , Tw.rounded_full
            ]
        ]
        [ text label ]


categoryToString : LearningResources.ResourceCategory -> String
categoryToString categoryUnion =
    case categoryUnion of
        LearningResources.CategoryLanguage_Or_CategoryPlatform_Or_CategoryTool__CategoryLanguage _ ->
            "Language"

        LearningResources.CategoryLanguage_Or_CategoryPlatform_Or_CategoryTool__CategoryPlatform _ ->
            "Platform"

        LearningResources.CategoryLanguage_Or_CategoryPlatform_Or_CategoryTool__CategoryTool _ ->
            "Tool"
