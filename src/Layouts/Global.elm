module Layouts.Global exposing (Model, Msg, Props, layout)

import Effect exposing (Effect)
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import Layout exposing (Layout)
import Route exposing (Route)
import Shared
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw
import View exposing (View)


type alias Props =
    {}


layout : Props -> Shared.Model -> Route () -> Layout () Model Msg contentMsg
layout props shared route =
    Layout.new
        { init = init
        , update = update
        , view = view
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
    = ReplaceMe


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ReplaceMe ->
            ( model
            , Effect.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view { toContentMsg, model, content } =
    { title = content.title ++ " | Developer Den"
    , body =
        [ Html.div
            [ Attr.class "page"
            , Attr.css
                [ Tw.min_h_screen
                , Tw.w_full
                , Tw.bg_color Tw.dd_deepblue
                , Tw.text_color Tw.white
                , Tw.font_sans
                , Tw.antialiased
                ]
            ]
            [ Html.div
                [ Attr.css [ Tw.max_w_7xl, Tw.mx_auto, Tw.px_8, Tw.py_12 ] ]
                content.body
            ]
        ]
    }
