module Views.About exposing (..)

import Views.MarkdownView as MD exposing (Model, Msg, initMarkdown)


type alias Msg =
    MD.Msg


type alias Model =
    MD.Model


init =
    initMarkdown "content/about.md"


update =
    MD.update


view =
    MD.view


toSession =
    MD.toSession
