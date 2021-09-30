module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Html, text)
import Json.Decode exposing (Value)
import Page
import Route exposing (Route)
import Session exposing (Session)
import Url exposing (Url)
import Viewer exposing (Viewer)
import Views.Learning as Learning


main : Program Value Model Msg
main =
    Browser.application Viewer

        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        }



init : Maybe Viewer -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    changeRouteTo
        (Route.fromUrl url)
        Home
        (Session.fromViewer navKey


type Model
    = Home Session
    | Learning Session String
    | NotFound Session


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotLearningMsg Learning.Msg


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( NotFound, Cmd.none )

        Just Route.Home ->
            ( Home, Cmd.none )

        Just (Route.Learning topic) ->
            Learning.init topic |> (\( _, b ) -> ( Learning topic, Cmd.map GotLearningMsg b ))


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl (Debug.log (Debug.toString url) url)) model

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    case url.fragment of
                        Nothing ->
                            -- If we got a link that didn't include a fragment,
                            -- it's from one of those (href "") attributes that
                            -- we have to include to make the RealWorld CSS work.
                            --
                            -- In an application doing path routing instead of
                            -- fragment-based routing, this entire
                            -- `case url.fragment of` expression this comment
                            -- is inside would be unnecessary.
                            ( model, Cmd.none )

                        Just _ ->
                            ( model
                            , Nav.pushUrl (Session.navKey (toSession model)) (Url.toString url)
                            )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ( _, m ) ->
            changeRouteTo (Debug.log (Debug.toString msg) (Just Route.Home)) model


toSession : Model -> Session
toSession page =
    case page of
        NotFound session ->
            session

        Home home ->
            Home.toSession home

        Settings settings ->
            Settings.toSession settings

        Login login ->
            Login.toSession login

        Register register ->
            Register.toSession register

        Profile _ profile ->
            Profile.toSession profile

        Article article ->
            Article.toSession article

        Editor _ editor ->
            Editor.toSession editor



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    let
        viewPage page config =
            Page.view page config
    in
    case model of
        Home ->
            viewPage Page.Home { title = "Home", content = text "" }

        NotFound ->
            { title = "404", body = [ text "Not found" ] }

        Learning string ->
            viewPage Page.Learning { title = string, content = text <| "Learning " ++ string }
