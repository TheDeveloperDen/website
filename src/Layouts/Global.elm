module Layouts.Global exposing (Model, Msg, Props, layout)

import Css
import Effect exposing (Effect)
import Html.Styled as Html exposing (Html, a, div, img, nav, text)
import Html.Styled.Attributes as Attr exposing (css, href)
import Layout exposing (Layout)
import Redirects
import Route exposing (Route)
import Route.Path
import Shared
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw
import Theming
import View exposing (View)


type alias Props =
    { activePage : Route.Path.Path }


layout : Props -> Shared.Model -> Route () -> Layout () Model Msg contentMsg
layout props shared route =
    Layout.new
        { init = init
        , update = update
        , view = view props
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


view : Props -> { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view layoutProps { content } =
    { title = content.title ++ " | Developer Den"
    , body =
        [ Html.div
            [ Attr.class "page"
            , Attr.css
                [ Tw.min_h_screen
                , Tw.w_full
                , Tw.overflow_x_hidden
                , Tw.overflow_y_hidden
                , Tw.bg_color Tw.dd_deepblue
                , Tw.text_color Tw.white
                , Tw.font_sans
                , Tw.antialiased
                ]
            ]
            [ viewNavbar layoutProps.activePage
            , Html.div [ css [ Tw.flex_grow ] ]
                content.body
            ]
        ]
    }


viewNavbar : Route.Path.Path -> Html msg
viewNavbar activePage =
    nav
        [ css
            [ Tw.flex
            , Tw.justify_between
            , Tw.items_center
            , Tw.max_w_7xl
            , Tw.mx_auto
            , Tw.w_full
            , Tw.px_8
            , Tw.py_6
            ]
        ]
        [ a
            [ Route.Path.href Route.Path.Home_ |> Attr.fromUnstyled
            , css [ Theming.headingFont, Tw.text_xl, Tw.font_bold, Tw.no_underline, Theming.textGradient ]
            ]
            [ img
                [ Attr.src "/static/devden-logo.svg"
                , Attr.alt "Developer Den Logo"
                , css [ Tw.h_16, Tw.w_auto ]
                ]
                []
            ]
        , div [ css [ Tw.flex, Tw.gap_8 ] ]
            [ viewNavLink "home" Route.Path.Home_ (activePage == Route.Path.Home_)
            , viewNavLink "rules" Route.Path.Rules (activePage == Route.Path.Rules)
            , viewNavLink "learning" Route.Path.Learning (activePage == Route.Path.Learning)
            , a
                [ href Redirects.discordURL
                , Attr.target "_blank"
                , css
                    [ Theming.headingFont
                    , Tw.text_sm
                    , Tw.text_color Tw.slate_400
                    , Css.hover [ Tw.text_color Tw.white ]
                    , Tw.transition_colors
                    , Tw.no_underline
                    ]
                ]
                [ text "discord" ]
            ]
        ]


viewNavLink : String -> Route.Path.Path -> Bool -> Html msg
viewNavLink label path isActive =
    a
        [ Route.Path.href path |> Attr.fromUnstyled
        , css
            [ Theming.headingFont
            , Tw.pb_1
            , Tw.no_underline
            , if isActive then
                Tw.text_color Tw.white

              else
                Tw.text_color Tw.slate_400
            , Css.hover [ Tw.text_color Tw.white ]
            , Tw.transition_colors
            , Tw.relative
            ]
        ]
        [ text label
        , if isActive then
            div
                [ css
                    [ Tw.absolute
                    , Tw.bottom_0
                    , Tw.left_0
                    , Tw.right_0
                    , Tw.h_1
                    , Theming.brandGradientBg
                    ]
                ]
                []

          else
            text ""
        ]
