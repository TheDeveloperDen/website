module Views.MarkdownView exposing (Model, Msg(..), initMarkdown, renderBlock, renderInline, renderMarkdown, toSession, update, view)

import Html exposing (Html, details, div, h1, h2, text)
import Html.Attributes exposing (id)
import Http
import Markdown.Block as Block exposing (Block(..))
import Markdown.Inline as Inline exposing (Inline)
import Session exposing (Session)
import Tailwind as Tw


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
        div [ Tw.bg_opacity_80, Tw.bg_gray_700, Tw.text_white, Tw.flex, Tw.w_1over2, Tw.flex_col, Tw.object_contain ] <|
            renderMarkdown markdownContent
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
