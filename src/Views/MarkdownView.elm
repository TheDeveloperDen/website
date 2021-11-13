module Views.MarkdownView exposing (Model, Msg(..), initMarkdown, renderBlock, renderInline, renderMarkdown, toSession, update, view)

import Html exposing (Html, a, details, div, h1, h2, i, span, text, ul)
import Html.Attributes exposing (class, id)
import Http
import Markdown.Block as Block exposing (Block(..))
import Markdown.Inline as Inline exposing (Inline)
import Session exposing (Session)
import Tailwind as Tw
import Tailwind.LG
import Tailwind.MD as TwMD


type alias Model =
    { session : Session, markdownContent : String }


type Msg
    = Loading
    | LoadedFileContent (Result Http.Error String)


initMarkdown : String -> Session -> ( Model, Cmd Msg )
initMarkdown markdownFile session =
    ( Model session markdownFile
    , Http.get { url = markdownFile, expect = Http.expectString LoadedFileContent }
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Loading ->
            ( model, Cmd.none )

        LoadedFileContent (Ok content) ->
            ( { model | markdownContent = content }, Cmd.none )

        LoadedFileContent (Err err) ->
            ( { model | markdownContent = "Could not load Markdown file " ++ Debug.toString err }, Cmd.none )


view : Model -> { title : String, content : Html Msg }
view { session, markdownContent } =
    { title = "Learning"
    , content =
        div [ Tw.flex, TwMD.flex_row_reverse, Tw.flex_wrap ]
            [ div [ Tw.w_full, TwMD.w_5over6, Tw.bg_gray_900, Tw.text_white, Tw.flex_col, Tw.object_contain, Tw.pl_32 ] <|
                renderMarkdown markdownContent
            , div [ Tw.w_full, TwMD.w_1over6, Tw.bg_gray_800, Tw.px_2, Tw.text_center, Tw.fixed, Tw.bottom_0, TwMD.top_16, TwMD.pt_8, TwMD.left_0, Tw.h_16, TwMD.h_full, TwMD.border_r_4, TwMD.border_gray_900 ]
                [ div
                    [ TwMD.relative
                    , Tw.flex_grow
                    , Tw.mx_auto
                    , Tailwind.LG.float_left
                    , Tailwind.LG.px_6
                    ]
                    [ ul [ Tw.flex, Tw.flex_row, TwMD.flex_col, Tw.text_center, TwMD.text_left ]
                        [ a [ Tw.block, Tw.py_1, TwMD.py_3, Tw.pl_1, Tw.align_middle, Tw.text_gray_900, Tw.no_underline, Tw.hover__text_pink_900, Tw.border_b_2, Tw.border_gray_900 ]
                            [ i [ class "fas", class "fa-link", Tw.pr_0, TwMD.pr_3 ] []
                            , span [ Tw.pb_1, TwMD.pb_0, Tw.text_xs, Tw.text_gray_500, Tw.block, TwMD.inline_block ] [ text "Link Link Link Link" ]
                            ]
                        ]
                    ]
                ]
            ]
    }


renderMarkdown =
    Block.parse Nothing >> List.map renderBlock >> List.concat


renderBlock : Block b i -> List (Html msg)
renderBlock block =
    case block of
        Heading h 1 _ ->
            [ h1 [ Tw.text_6xl, Tw.underline, Tw.py_4 ] [ text h ] ]

        Heading h 2 _ ->
            [ h2 [ id <| formatToHtmlId h, Tw.text_5xl, Tw.py_3 ] [ text h ] ]

        BlockQuote blocks ->
            List.map renderBlock blocks |> List.concat |> details [] |> (\a -> [ a ])

        _ ->
            Block.defaultHtml (Just renderBlock) (Just renderInline) block


renderInline : Inline i -> Html msg
renderInline inline =
    Inline.defaultHtml (Just renderInline) inline


formatToHtmlId s =
    String.replace " " "-" s


toSession =
    .session
