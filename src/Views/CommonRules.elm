module Views.CommonRules exposing (..)

import Html exposing (Html, a, div, h1, h2, h3, li, p, text, ul)
import Html.Attributes exposing (href)
import Tailwind as Tw


rulesSection : Html msg -> Html msg -> List (Html msg) -> Html msg
rulesSection title subtitle body =
    div [ Tw.ml_16, Tw.mr_16, Tw.mb_20, Tw.text_white ]
        [ h1 [ Tw.text_6xl, Tw.font_cascadia, Tw.mt_2, Tw.py_2, Tw.text_center ] [ title ]
        , h2 [ Tw.text_2xl, Tw.py_2, Tw.font_montserrat, Tw.text_center ] [ subtitle ]
        , div [] body
        ]


ruleHeader body =
    h3 [ Tw.font_montserrat, Tw.text_3xl, Tw.py_2, Tw.mt_2 ] [ text body ]


rulesList : List (Html msg) -> Html msg
rulesList rules =
    ul [ Tw.space_y_1, Tw.list_disc ] (List.map (ruleLine << List.singleton) rules)


ruleLine : List (Html msg) -> Html msg
ruleLine text =
    li [ Tw.ml_10 ] [ p [ Tw.font_montserrat, Tw.text_xl ] text ]


inlineLink : String -> String -> Html msg
inlineLink val link =
    a [ Tw.text_indigo, Tw.underline, Tw.hover__text_blue_500, Tw.duration_300, Tw.ease_in_out, href link ] [ text val ]
