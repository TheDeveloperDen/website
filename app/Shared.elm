module Shared exposing (Data, Model, Msg, template)

import BackendTask exposing (BackendTask)
import Css
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Html exposing (Html)
import Html.Styled as Styled exposing (a, div, nav, text)
import Html.Styled.Attributes as Attr exposing (css, href)
import Html.Styled.Events as Events
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Ports
import Redirects
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw
import Theming
import UrlPath exposing (UrlPath)
import View exposing (View)


template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Nothing
    }


type Msg
    = SetTheme Theme


type Theme
    = Light
    | Dark


type alias Data =
    ()


type alias Model =
    {}


init :
    Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : UrlPath
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Effect Msg )
init _ _ =
    ( {}, Effect.none )


update : Msg -> Model -> ( Model, Effect Msg )
update (SetTheme theme) model =
    ( model, Effect.fromCmd (Ports.setTheme (themeToString theme)) )


subscriptions : UrlPath -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : BackendTask FatalError Data
data =
    BackendTask.succeed ()


view :
    Data
    ->
        { path : UrlPath
        , route : Maybe Route
        }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : List (Html msg), title : String }
view _ page _ toMsg pageView =
    { title = pageView.title ++ " | Developer Den"
    , body =
        [ Styled.toUnstyled
            (div
                [ Attr.class "page"
                , css
                    [ Tw.min_h_screen
                    , Tw.w_full
                    , Tw.overflow_x_hidden
                    , Tw.bg_color Tw.dd_deepblue
                    , Tw.text_color Tw.white
                    , Tw.font_sans
                    , Tw.antialiased
                    , Tw.flex
                    , Tw.flex_col
                    ]
                ]
                [ viewNavbar toMsg page.route
                , div [ css [ Tw.flex_grow, Tw.flex, Tw.flex_col ] ]
                    (List.map Styled.fromUnstyled pageView.body)
                ]
            )
        ]
    }


viewNavbar : (Msg -> msg) -> Maybe Route -> Styled.Html msg
viewNavbar toMsg activeRoute =
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
            [ routeHref Route.Index
            , css [ Tw.block ]
            ]
            (Theming.themedImage
                { dark = "/devden-logo.svg", light = "/devden-logo-light.svg", alt = "Developer Den Logo" }
                [ Tw.h_16, Tw.w_auto, Tw.block ]
            )
        , div [ css [ Tw.flex, Tw.gap_8 ] ]
            [ viewNavLink "home" Route.Index (activeRoute == Just Route.Index)
            , viewNavLink "rules" Route.Rules (activeRoute == Just Route.Rules)
            , viewNavLink "learning" Route.Learning (isLearning activeRoute)
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
            , viewThemeToggle toMsg
            ]
        ]


themeToString : Theme -> String
themeToString theme =
    case theme of
        Light ->
            "light"

        Dark ->
            "dark"


viewThemeToggle : (Msg -> msg) -> Styled.Html msg
viewThemeToggle toMsg =
    Styled.span []
        [ Styled.span [ Attr.class "on-dark" ] [ themeButton (toMsg (SetTheme Light)) "light mode" ]
        , Styled.span [ Attr.class "on-light" ] [ themeButton (toMsg (SetTheme Dark)) "dark mode" ]
        ]


themeButton : msg -> String -> Styled.Html msg
themeButton msg label =
    Styled.button
        [ Attr.type_ "button"
        , Events.onClick msg
        , css
            [ Theming.headingFont
            , Theming.quietLink
            , Tw.bg_color Tw.transparent
            , Tw.border_0
            , Tw.p_0
            , Tw.pb_1
            , Tw.cursor_pointer
            , Css.property "font-size" "inherit"
            , Css.property "line-height" "inherit"
            ]
        ]
        [ text label ]


isLearning : Maybe Route -> Bool
isLearning activeRoute =
    case activeRoute of
        Just Route.Learning ->
            True

        Just (Route.Learning__Resource_ _) ->
            True

        _ ->
            False


routeHref : Route -> Styled.Attribute msg
routeHref route =
    href (UrlPath.toAbsolute (Route.toPath route))


viewNavLink : String -> Route -> Bool -> Styled.Html msg
viewNavLink label route isActive =
    a
        [ routeHref route
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
