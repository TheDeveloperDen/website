module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask
import Css
import Head
import Head.Seo as Seo
import Html.Styled exposing (Html, a, div, h1, i, p, text)
import Html.Styled.Attributes as Attr exposing (css, href, target)
import Pages.Url
import PagesMsg exposing (PagesMsg)
import Redirects
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Tailwind.Breakpoints as Breakpoints
import Tailwind.Utilities as Tw
import Theming
import UrlPath
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    ()


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = BackendTask.succeed ()
        }
        |> RouteBuilder.buildNoState { view = view }


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "Developer Den"
        , image =
            { url = UrlPath.fromString "devden-banner.svg" |> Pages.Url.fromPath
            , alt = "Developer Den"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Developer Den is a community of programmers learning and building together."
        , locale = Nothing
        , title = "Home"
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromStyled "Home"
        [ div [ css [ Tw.flex, Tw.flex_col, Tw.items_center, Tw.justify_center, Tw.w_full, Tw.flex_grow, Theming.gutter, Tw.py_16 ] ]
            [ viewHero ]
        ]
        |> View.map PagesMsg.fromMsg


viewHero : Html Msg
viewHero =
    div [ css [ Tw.text_center, Tw.flex, Tw.flex_col, Tw.items_center ] ]
        [ viewTitle
        , p
            [ css
                [ Theming.bodyFont
                , Tw.text_xl
                , Breakpoints.md [ Tw.text_2xl ]
                , Tw.max_w_2xl
                , Tw.leading_relaxed
                , Tw.mt_10
                , Tw.mb_12
                , Tw.mx_0
                ]
            ]
            [ text "A closely-knit community anchored in a common passion for programming." ]
        , div [ css [ Tw.flex, Tw.flex_col, Tw.w_full, Tw.max_w_xs, Tw.gap_4, Breakpoints.sm [ Tw.flex_row, Tw.w_auto, Tw.max_w_none ] ] ]
            [ viewButton Redirects.discordURL "fab fa-discord" "join our discord"
            , viewButton Redirects.githubURL "fab fa-github" "view our github"
            ]
        ]


{-| A fake text layer on top of the SVG logo to allow the text to be highlighted and read by screen readers etc 
-}
viewTitle : Html Msg
viewTitle =
    div
        [ css
            [ Tw.relative
            , Tw.w_full
            , Tw.max_w_3xl
            , Css.property "container-type" "inline-size"
            ]
        ]
        (Theming.themedImage
            { dark = "/devden-title.svg", light = "/devden-title-light.svg", alt = "" }
            [ Tw.block, Tw.w_full, Tw.h_auto ]
            ++ [ h1
                    [ css
                        [ Theming.headingFont
                        , Tw.absolute
                        , Tw.inset_0
                        , Css.property "top" "-1.2cqw"
                        , Tw.m_0
                        , Tw.text_left
                        , Tw.whitespace_nowrap
                        , Tw.font_normal
                        , Css.property "font-size" "12.86cqw"
                        , Tw.leading_none
                        , Css.property "padding-left" "1.5%"
                        , Css.property "color" "transparent"
                        ]
                    ]
                    [ text "developer den" ]
               ]
        )


viewButton : String -> String -> String -> Html Msg
viewButton url iconClass label =
    a
        [ href url
        , target "_blank"
        , css [ Theming.gradientButton, Tw.w_full, Breakpoints.sm [ Tw.w_auto ] ]
        ]
        [ i [ Attr.class iconClass, css [ Tw.text_2xl ] ] []
        , text label
        ]
