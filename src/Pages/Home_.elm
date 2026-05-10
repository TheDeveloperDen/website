module Pages.Home_ exposing (page)

import Css
import Css.Global
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import Tailwind.Breakpoints as Breakpoints
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw
import View exposing (View)


page : View msg
page =
    { title = "Homepage"
    , body =
        [ Html.a
            [ Attr.css
                [ Tw.inline_flex
                , Tw.items_center
                , Tw.justify_center
                , Tw.px_5
                , Tw.py_3
                , Tw.border
                , Tw.border_color Tw.transparent
                , Tw.text_base
                , Tw.font_medium
                , Tw.rounded_md
                , Tw.text_color Tw.white
                , Tw.bg_color Tw.indigo_600
                , Css.hover [ Tw.bg_color Tw.indigo_700 ]
                ]
            ]
            [ Html.text "Hello, world!" ]
        ]
    }
