module Pages.Learning exposing (Model, Msg, page)

import Api
import Effect exposing (Effect)
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Json.Encode
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
import View exposing (View)
import Dict
import Html.Styled.Events exposing (onInput)

page : Shared.Model -> Route () -> Page Model Msg
page shared _ =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view shared
        }
        |> Page.withLayout (\_ -> Layouts.Global {})



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
        [ Html.div [ Attr.css [ Tw.pt_12, Tw.pb_24, Tw.max_w_7xl, Tw.mx_auto ] ]
            [ viewHeader model.searchQuery
            , case shared.learningDatabase of
                SharedModel.Loading ->
                    Html.div [ Attr.css [ Tw.text_center, Tw.text_color Tw.gray_400 ] ] [ Html.text "Loading learning directory..." ]

                SharedModel.Failure _ ->
                    Html.div [ Attr.css [ Tw.text_center, Tw.text_color Tw.red_400 ] ] [ Html.text "Failed to load directory." ]

                SharedModel.Success db ->
                    viewCategorizedGrid model.searchQuery db.metadata
            ]
        ]
    }


viewHeader : String -> Html Msg
viewHeader query =
    Html.div [ Attr.css [ Tw.flex, Tw.flex_col, Tw.items_center, Tw.text_center, Tw.mb_16 ] ]
        [ Html.h1
            [ Attr.css [ Tw.text_5xl, Tw.font_bold, Tw.tracking_widest, Tw.uppercase, Tw.mb_4 ] ]
            [ Html.text "LEARNING RESOURCES" ]
        , Html.p
            [ Attr.css [ Tw.text_lg, Tw.text_color Tw.gray_400, Tw.max_w_2xl, Tw.mb_8 ] ]
            [ Html.text "Explore our curated directory of programming languages, tools, and concepts." ]
        , Html.input
            [ Attr.value query
            , onInput SearchQueryChanged
            , Attr.placeholder "Search topics or domains (e.g., 'Rust', 'Web')..."
            , Attr.css
                [ Tw.w_full
                , Tw.max_w_lg
                , Tw.p_4
                , Tw.rounded_xl
                , Tw.bg_color Tw.slate_800
                , Tw.border
                , Tw.border_color Tw.slate_700
                , Tw.text_color Tw.white
                -- , Tw.focus__border_fuchsia_500
                -- , Tw.focus__outline_none
                ]
            ]
            []
        ]


viewCategorizedGrid : String -> List LearningResources.CompiledMeta -> Html Msg
viewCategorizedGrid query metadata =
    let
        q =
            String.toLower query

        -- Filter by name or domains
        filtered =
            List.filter
                (\meta ->
                    String.contains q (String.toLower meta.name)
                        || List.any (\domain -> String.contains q (String.toLower (LearningResources.languageDomainToString domain))) meta.domains
                )
                metadata

        -- Group by category. (Decoding the Json.Encode.Value to a string)
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
    Html.div [ Attr.css [ Tw.flex, Tw.flex_col, Tw.gap_16 ] ]
        (Dict.toList grouped
            |> List.map (\( category, items ) -> viewCategorySection category items)
        )


viewCategorySection : String -> List LearningResources.CompiledMeta -> Html msg
viewCategorySection category items =
    Html.div []
        [ Html.h2
            [ Attr.css [ Tw.text_2xl, Tw.font_bold, Tw.mb_6, Tw.border_b, Tw.border_color Tw.slate_700, Tw.pb_2 ] ]
            [ Html.text category ]
        , Html.div
            [ Attr.css [ Tw.grid, Tw.grid_cols_1, Tw.gap_6 ] ]
            (List.map viewTopicCard items)
        ]

viewTopicCard : LearningResources.CompiledMeta -> Html msg
viewTopicCard meta =
    Html.a
        [ Route.Path.href (Route.Path.Learning_Resource_ { resource = LearningResources.entityTagToString meta.id })
            |> Attr.fromUnstyled
        , Attr.css
            [ Tw.flex
            , Tw.flex_col
            , Tw.bg_color Tw.slate_700
            , Tw.rounded_xl
            , Tw.p_6
            , Tw.border
            , Tw.border_color Tw.slate_700
            , Tw.transition_colors
            , Tw.cursor_pointer
            ]
        ]
        [ Html.div [ Attr.css [ Tw.flex, Tw.items_center, Tw.mb_4, Tw.gap_3 ] ]
            [ Html.div [ Attr.css [ Tw.text_3xl ] ] [ Html.text (Maybe.withDefault "📄" meta.emoji) ]
            , Html.h3 [ Attr.css [ Tw.font_bold, Tw.text_xl, Tw.text_color Tw.white ] ] [ Html.text meta.name ]
            ]
        , Html.p [ Attr.css [ Tw.text_sm, Tw.text_color Tw.gray_400, Tw.flex_grow, Tw.mb_6 ] ]
            [ Html.text meta.description ]
        , Html.div [ Attr.css [ Tw.flex, Tw.flex_wrap, Tw.gap_2 ] ]
            (List.map (\domain -> viewBadge (LearningResources.languageDomainToString domain)) meta.domains)
        ]

viewBadge : String -> Html msg
viewBadge label =
    Html.span
        [ Attr.css
            [ Tw.text_xs
            , Tw.font_medium
            , Tw.bg_color Tw.slate_700
            , Tw.text_color Tw.slate_300
            , Tw.px_2
            , Tw.py_1
            , Tw.rounded_full
            ]
        ]
        [ Html.text label ]


categoryToString : LearningResources.ResourceCategory -> String
categoryToString categoryUnion =
    case categoryUnion of
        LearningResources.CategoryLanguage_Or_CategoryPlatform_Or_CategoryTool__CategoryLanguage _ ->
            "Language"

        LearningResources.CategoryLanguage_Or_CategoryPlatform_Or_CategoryTool__CategoryPlatform _ ->
            "Platform"

        LearningResources.CategoryLanguage_Or_CategoryPlatform_Or_CategoryTool__CategoryTool _ ->
            "Tool"