module Pages.Learning exposing (Model, Msg, page)

import Api
import Effect exposing (Effect)
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import LearningResources
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Shared.Model as SharedModel
import View exposing (View)
import Route.Path

page : Shared.Model -> Route () -> Page Model Msg
page shared _ =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view shared
        }


type alias Model =
    {}


type Msg
    = NoOp


init : () -> ( Model, Effect Msg )
init _ =
    ( {}
    , Effect.none
    )


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Effect.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Shared.Model -> Model -> View Msg
view shared _ =
    { title = "Learning"
    , body =
        case shared.learningIndex of
            SharedModel.Loading ->
                [ Html.text "Loading learning resources..." ]

            SharedModel.Failure error ->
                [ Html.text "Failed to load learning resources :("
                , Html.div [] [ Html.text (Api.toUserFriendlyMessage error) ]
                ]

            SharedModel.Success entries ->
                [ Html.div
                    [ Attr.class "learning-cards" ]
                    (List.map viewCard entries)
                ]
    }


viewCard : LearningResources.ResourceIndexEntry -> Html.Html msg
viewCard entry =
    Html.article
        [ Attr.class "learning-card" ]
        [ Html.h3 [] [ Html.text entry.name ]
        , Html.a [ 
            Route.Path.href ( Route.Path.Learning_Resource_ { resource = entry.name })
            |> Attr.fromUnstyled 
        ] [ Html.text "Click to browse resources" ]
        ]
