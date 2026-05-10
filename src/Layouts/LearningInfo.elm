module Layouts.LearningInfo exposing (LearningInfoMode(..), Model, Msg, Props, layout)

import Api
import Effect exposing (Effect)
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import Layout exposing (Layout)
import LearningResources
import Route exposing (Route)
import Shared
import Shared.Model as SharedModel
import View exposing (View)


type alias Props =
    { mode : LearningInfoMode }


type LearningInfoMode
    = CardsMode -- ^ Show the index of learning resources as cards
    | SidebarMode -- ^ Show the index as a sidebar


layout : Props -> Shared.Model -> Route () -> Layout () Model Msg contentMsg
layout props shared _ =
    Layout.new
        { init = init
        , update = update
        , view = view props shared
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init _ =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = NoOp


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



-- VIEW


view : Props -> Shared.Model -> { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view props shared { content } =
    { title = content.title
    , body =
        case shared.learningIndex of
            SharedModel.Loading ->
                [ Html.text "Loading learning resources..." ]

            SharedModel.Failure error ->
                [ Html.text "Failed to load learning resources :("
                , Html.div [] [ Html.text (Api.toUserFriendlyMessage error) ]
                ]

            SharedModel.Success entries ->
                case props.mode of
                    CardsMode ->
                        [ Html.div
                            [ Attr.class "learning-cards" ]
                            (List.map viewCard entries)
                        ]

                    SidebarMode ->
                        [ Html.div
                            [ Attr.class "learning-layout" ]
                            [ Html.aside
                                [ Attr.class "learning-sidebar" ]
                                [ Html.h3 [] [ Html.text "Languages" ]
                                , Html.ul [] (List.map viewSidebarItem entries)
                                ]
                            , Html.main_
                                [ Attr.class "learning-content" ]
                                content.body
                            ]
                        ]
    }


viewCard : LearningResources.ResourceIndexEntry -> Html.Html msg
viewCard entry =
    Html.article
        [ Attr.class "learning-card" ]
        [ Html.h3 [] [ Html.text entry.name ]
        , Html.p [] [ Html.text "Click to browse resources" ]
        ]


viewSidebarItem : LearningResources.ResourceIndexEntry -> Html.Html msg
viewSidebarItem entry =
    Html.li [] [ Html.text entry.name ]
