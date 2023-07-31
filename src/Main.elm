module Main exposing (Model, Msg, main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html
import Page
import Route exposing (Route(..))
import Url exposing (Url)
import Views.Home as Home
import Views.LearningResources as LearningResources
import Views.Rules as Rules
import Views.ServicesRules as ServicesRules


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
    changeRouteTo (Route.maybeFromUrl url) { key = key, page = EmptyModel }


type alias Model =
    { key : Nav.Key
    , page : PageModel
    }


type PageModel
    = EmptyModel
    | NotFound
    | HomeModel
    | RulesModel
    | ServicesRulesModel
    | LearningResourcesModel (Maybe String) LearningResources.Model
    | DiscordModel


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | NewPage
    | GotLRMsg LearningResources.Msg
    | GotNullMsg ()


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | page = NotFound }, Cmd.none )

        Just Home ->
            ( { model | page = HomeModel }, Cmd.none )

        Just Discord ->
            ( { model | page = DiscordModel }, Nav.load (Route.routeToString Route.Discord) )

        Just (LearningResources res) ->
            let
                ( learningModel, cmd ) =
                    LearningResources.init res
            in
            ( { model | page = LearningResourcesModel res learningModel }, Cmd.map GotLRMsg cmd )

        Just Rules ->
            ( { model | page = RulesModel }, Cmd.none )

        Just ServicesRules ->
            ( { model | page = ServicesRulesModel }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( ChangedUrl url, _ ) ->
            let
                route =
                    Route.maybeFromUrl url
            in
            changeRouteTo route model

        ( ClickedLink request, _ ) ->
            case request of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ( GotLRMsg lrMsg, LearningResourcesModel r lrm ) ->
            let
                ( lrModel, lrMsg2 ) =
                    LearningResources.update lrMsg lrm
            in
            ( { model | page = LearningResourcesModel r lrModel }, Cmd.map GotLRMsg lrMsg2 )

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
    let
        page =
            case model.page of
                HomeModel ->
                    Page.map GotNullMsg <| Page.view Page.Home (Home.view ())

                RulesModel ->
                    Page.map GotNullMsg <| Page.view Page.Rules (Rules.view ())

                ServicesRulesModel ->
                    Page.map GotNullMsg <| Page.view Page.ServicesRules (ServicesRules.view ())

                LearningResourcesModel res m ->
                    Page.map GotLRMsg (Page.view (Page.LearningResources res) (LearningResources.view m))

                DiscordModel ->
                    -- default to home, this should never happen
                    Page.map GotNullMsg <| Page.view Page.Home (Home.view ())

                EmptyModel ->
                    Page.map GotNullMsg <| Page.view Page.Home (Home.view ())

                NotFound ->
                    Page.map GotNullMsg <| Page.view Page.Home (Home.view ())

        -- TODO 404 page
    in
    { title = page.title, body = List.map (Html.map (\_ -> NewPage)) page.body }
