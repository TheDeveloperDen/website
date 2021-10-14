module Views.MarkdownView exposing (..)

import Html exposing (Html, details, div, h1, h2, text)
import Http
import Markdown
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
    , content = div [ Tw.bg_gray_700, Tw.text_white, Tw.flex, Tw.w_auto, Tw.flex_col, Tw.justify_center, Tw.items_center, Tw.content_center ] <| Markdown.toHtml Nothing markdownContent
    }


renderMarkdown =
    Block.parse Nothing >> List.map renderBlock >> List.concat >> div []


renderBlock : Block b i -> List (Html msg)
renderBlock block =
    case block of
        Heading h 1 inlines ->
            [ h1 [ Tw.text_xl ] [ text h ] ]

        Heading h 2 inlines ->
            [ h2 [ Tw.text_xl ] [ text h ] ]

        BlockQuote blocks ->
            List.map renderBlock blocks |> List.concat |> details [] |> (\a -> [ a ])

        _ ->
            Block.defaultHtml (Just renderBlock) (Just renderInline) block


renderInline : Inline i -> Html msg
renderInline inline =
    Inline.defaultHtml (Just renderInline) inline


toSession =
    .session
