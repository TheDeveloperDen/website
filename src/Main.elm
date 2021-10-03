module Main exposing (main)

import Api exposing (Cred)
import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Html, text)
import Json.Decode exposing (Decoder, Value)
import Page
import Route exposing (Route)
import Session exposing (Session)
import Url exposing (Url)
import Viewer exposing (Viewer)
import Views.Blank as Blank
import Views.Home as Home exposing (Msg(..))
import Views.Learning as Learning


main : Program Value Model Msg
main =
    Api.application Viewer.decoder
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        }


init : Maybe Viewer -> Url -> Nav.Key -> ( Model, Cmd Msg )
init maybeViewer url navKey =
    changeRouteTo
        (Route.fromUrl url)
        (Redirect
            (Session.fromViewer navKey maybeViewer)
        )


type Model
    = Home Home.Model
    | Redirect Session
    | Learning Learning.Model
    | NotFound Session


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotLearningMsg Learning.Msg
    | GotHomeMsg Home.Msg


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just Route.Home ->
            Home.init session |> updateWith Home GotHomeMsg model

        Just Route.Learning ->
            Learning.init session |> updateWith Learning GotLearningMsg model


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( GotLearningMsg subMsg, Learning topic ) ->
            Learning.update subMsg topic |> updateWith Learning GotLearningMsg model

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
            changeRouteTo (Just Route.Home) model


toSession : Model -> Session
toSession page =
    case page of
        Redirect session ->
            session

        NotFound session ->
            session

        Home home ->
            Home.toSession home

        Learning learning ->
            Learning.toSession learning



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    let
        viewer =
            toSession model |> Session.viewer

        viewPage page toMsg config =
            let
                { title, body } =
                    Page.view viewer page config
            in
            { title = title, body = List.map (Html.map toMsg) body }
    in
    case model of
        Redirect _ ->
            Page.view viewer Page.Other Blank.view

        Home home ->
            viewPage Page.Home GotHomeMsg (Home.view home)

        NotFound _ ->
            { title = "404", body = [ text "Not found" ] }

        Learning topic ->
            viewPage Page.Learning GotLearningMsg (Learning.view topic)
