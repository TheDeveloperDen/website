module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Html)
import Page exposing (view)
import Route exposing (Route(..))
import Url exposing (Url)
import Views.Home as Home
import Views.Rules as Rules


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        }


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { route = ( Route.fromUrl url )
      , key = key
      }
      , Cmd.none
    )


type alias Model =
    { route : Route
    , key : Nav.Key
    }


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotHomeMsg
    | GotRulesMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangedUrl url ->
            ( { route = (Route.fromUrl url)
              , key = model.key }
            , Cmd.none
            )

        ClickedLink request ->
            case request of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        _ ->
            ( model
            , Cmd.none
            )


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    case model.route of
        Home ->
            let
                page =
                    Page.view Page.Home ( Home.view { key = model.key } )
            in
            { title = page.title, body = List.map ( Html.map (\_ -> GotHomeMsg) ) page.body }

        Rules ->
            let
                page =
                    Page.view Page.Rules ( Rules.view { key = model.key } )
            in
            { title = page.title, body = List.map ( Html.map (\_ -> GotRulesMsg) ) page.body }
