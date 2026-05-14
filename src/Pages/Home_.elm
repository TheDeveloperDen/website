module Pages.Home_ exposing (Model, Msg, page)

import Css
import Effect exposing (Effect)
import Html.Styled as Html exposing (Html, a, div, fieldset, h1, h2, i, img, legend, p, text)
import Html.Styled.Attributes as Attr exposing (css, href, target)
import Layouts
import Page exposing (Page)
import Redirects
import Route exposing (Route)
import Route.Path
import Shared
import Tailwind.Breakpoints as Breakpoints
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw
import Theming


page : Shared.Model -> Route () -> Page Model Msg
page _ _ =
    Page.new
        { init = \_ -> ( {}, Effect.none )
        , update = \_ model -> ( model, Effect.none )
        , subscriptions = \_ -> Sub.none
        , view = \_ -> view
        }
        |> Page.withLayout (\_ -> Layouts.Global { activePage = Route.Path.Home_ })


type alias Model =
    {}


type Msg
    = NoOp


view : { title : String, body : List (Html Msg) }
view =
    { title = "Home"
    , body =
        [ div
            [ css
                [ Tw.flex
                , Tw.flex_col
                , Tw.items_center
                , Tw.justify_center
                , Tw.w_full
                , Tw.flex_grow
                , Tw.px_6
                ]
            ]
            [ viewBanner
            ]
        , viewFloatingSocials
        ]
    }


viewBanner : Html Msg
viewBanner =
    div [ css [ Tw.text_center ] ]
        [ img
            [ Attr.src "/static/devden-banner.svg"
            , Attr.alt "Developer Den Banner"
            , css
                [ Theming.headingFont
                , Tw.font_bold
                , Tw.mb_2
                , Theming.textGradient
                , Tw.inline_block
                , Tw.tracking_widest
                , Tw.pb_2
                , Tw.block
                , Tw.mx_auto
                ]
            ]
            []
        , h2
            [ css
                [ Theming.bodyFont
                , Tw.text_xl
                , Breakpoints.md [ Tw.text_2xl ]
                , Tw.text_color Tw.gray_300
                , Tw.max_w_3xl
                , Tw.mx_auto
                , Tw.mb_10
                , Tw.leading_relaxed
                ]
            ]
            [ text "A closely-knit community anchored in a common passion for programming." ]
        , a
            [ href Redirects.discordURL
            , target "_blank"
            , css
                [ Tw.font_sans
                , Tw.tracking_wide
                , Tw.text_lg
                , Tw.font_bold
                , Tw.text_color Tw.white
                , Theming.brandGradientBg
                , Tw.px_8
                , Tw.py_4
                , Tw.rounded_2xl
                , Tw.no_underline
                , Css.hover [ Tw.opacity_90, Tw.scale_105 ]
                , Tw.transition_all
                , Tw.inline_flex
                , Tw.items_center
                , Tw.justify_center
                , Tw.gap_3
                , Tw.drop_shadow_lg
                ]
            ]
            [ i [ Attr.class "fab fa-discord", css [ Tw.text_3xl ] ] []
            , text "Interested? Join our Discord!"
            ]
        ]


viewFloatingSocials : Html Msg
viewFloatingSocials =
    div
        [ css
            [ Tw.fixed
            , Tw.bottom_6
            , Tw.right_6
            , Tw.flex
            , Tw.gap_2
            , Tw.bg_color Tw.slate_800
            , Tw.p_2
            , Tw.rounded_xl
            , Tw.border
            , Tw.border_color Tw.slate_700
            , Tw.drop_shadow_lg
            , Tw.z_50
            ]
        ]
        [ viewSocialIcon Redirects.discordURL
            (i [ Attr.class "fab fa-discord", css [ Tw.text_2xl ] ] [])
            (Tw.text_color Tw.indigo_400)
        , viewSocialIcon Redirects.githubURL
            (i [ Attr.class "fab fa-github", css [ Tw.text_2xl ] ] [])
            (Tw.text_color Tw.white)
        ]


viewSocialIcon : String -> Html Msg -> Css.Style -> Html Msg
viewSocialIcon url icon hoverStyle =
    a
        [ href url
        , target "_blank"
        , css
            [ Tw.text_color Tw.gray_400
            , Css.hover [ hoverStyle ]
            , Tw.transition_colors
            , Tw.p_2
            , Tw.block
            ]
        ]
        [ icon ]
