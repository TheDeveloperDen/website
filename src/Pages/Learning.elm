module Pages.Learning exposing (Model, Msg, page)

import Api
import Effect exposing (Effect)
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import Layouts
import LearningResources
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
import Shared.Model as SharedModel
import Tailwind.Breakpoints as Breakpoints
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared _ =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view shared
        }
        |> Page.withLayout Layouts.Global


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
                [ Html.div []
                    [ Html.h1 [] [ Html.text "Learning Resources" ]
                    , Html.div
                        [ Attr.class "learning-cards" ]
                        (List.map viewCard entries)
                    ]
                ]
    }



viewCardGrid =
    Html.div 
        [ Attr.css 
            [ Tw.grid
            , Tw.grid_cols_1
            , Tw.md__grid_cols_3 -- 3 columns on desktop
            , Tw.gap_8
            , Tw.mt_12
            ] 
        ]
        [ viewCard "Web Frontend"
        , viewCard "Backend"
        , viewCard "Systems"
        ]

viewCard : String -> Html msg
viewCard title =
    div 
        [ css 
            [ Tw.flex
            , Tw.flex_col
            , Tw.rounded_xl
            , Tw.overflow_hidden
            , Tw.border
            , Tw.border_slate_700
            ] 
        ]
        [ -- Top white half
          div [ css [ Tw.bg_white, Tw.h_32, Tw.w_full ] ] []
          -- Bottom dark half
        , div [ css [ Tw.bg_slate_800, Tw.p_4, Tw.flex_grow ] ]
            [ Html.h3 [ css [ Tw.font_bold, Tw.text_lg, Tw.mb_2 ] ] [ text title ]
            , Html.p [ css [ Tw.text_xs, Tw.text_gray_400 ] ] 
                [ text "This is the front-end website that you are viewing right now..." ]
            ]
        ]

viewCard : LearningResources.ResourceIndexEntry -> Html.Html msg
viewCard entry =
    Html.div
        [ Attr.css
            [ Tw.bg_color Tw.dd_deepblue
            , Tw.text_color Tw.white
            , Tw.border
            , Tw.rounded_xl
            , Tw.p_6
            ]
        ]
        [ Html.article
            [ Attr.class "learning-card" ]
            [ Html.h3 [] [ Html.text entry.name ]
            , Html.a
                [ Route.Path.href (Route.Path.Learning_Resource_ { resource = entry.name })
                    |> Attr.fromUnstyled
                ]
                [ Html.text "Click to browse resources" ]
            ]
        ]
