module Main exposing (main)

import Browser
import Html exposing (Html, text, pre)
import Http exposing (Error)

main = Browser.element
   {  init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

type Model = Failure Error | Success String | Loading

init : () -> (Model, Cmd Msg)
init _ =
  ( Loading
  , Http.get
      { url = "https://developerden.net/learning-resources"
      , expect = Http.expectString GotText
      }
  )



-- UPDATE


type Msg
  = GotText (Result Http.Error String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotText result ->
      case result of
        Ok fullText ->
          (Success fullText, Cmd.none)

        Err s ->
          (Failure s, Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  case model of
    Failure _ ->
      text ("I was unable to load your book.")

    Loading ->
      text "Loading..."

    Success fullText ->
      pre [] [ text fullText ]
