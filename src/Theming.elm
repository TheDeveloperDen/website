module Theming exposing (..)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw


brandGradientBg : Css.Style
brandGradientBg =
    -- elm tailwind doesnt seem to play well with this
    Css.property "background-image"
        "linear-gradient(to right, var(--color-den-teal), var(--color-den-indigo), var(--color-den-pink))"


textGradient : Css.Style
textGradient =
    Css.batch
        [ brandGradientBg
        , Css.property "-webkit-background-clip" "text"
        , Css.property "background-clip" "text"
        , Css.property "-webkit-text-fill-color" "transparent"
        , Css.color Css.transparent
        ]


headingFont : Css.Style
headingFont =
    Css.batch [ Tw.font_mono, Tw.text_white ]


bodyFont : Css.Style
bodyFont =
    Css.batch [ Tw.font_sans, Tw.text_gray_300 ]


cardShell : List Css.Style -> List (Html msg) -> Html msg
cardShell extraStyles children =
    Html.div
        [ Attr.css
            ([ Tw.bg_color Tw.dd_deepblueLighter
             , Tw.rounded_xl
             , Tw.overflow_hidden
             , Tw.border
             , Tw.border_color Tw.slate_700
             ]
                ++ extraStyles
            )
        ]
        children
