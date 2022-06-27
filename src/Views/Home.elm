module Views.Home exposing (Model, Msg, view)

import Browser.Navigation as Nav
import Html exposing (Html, a, button, div, h1, h2, i, text)
import Html.Attributes exposing (class, href)
import Redirects exposing (discordURL, githubURL)
import Tailwind as Tw


type alias Model =
    { key : Nav.Key
    }


type alias Msg =
    ()


view : Model -> { title : String, content : Html Msg }
view _ =
    { title = "Home"
    , content =
        div [ Tw.flex, Tw.flex_col, Tw.my_auto, Tw.h_auto, Tw.items_center, Tw.justify_center, Tw.text_white ]
            [ h1 [ Tw.text_center, Tw.text_9xl, class "horta" ] [ text "Developer Den" ]
            , h2 [ Tw.text_center, Tw.font_titillium, Tw.text_2xl, Tw.py_4 ] [ text "A closely-knit community anchored in a common passion for programming." ]
            , div [ Tw.py_7 ]
                  [ a [ href discordURL, Tw.bg_indigo_500, Tw.text_2xl, Tw.p_5, Tw.rounded_2xl, Tw.shadow_md, Tw.hover__bg_indigo_600, Tw.ease_in_out, Tw.duration_300 ]
                      [ button [ Tw.font_titillium, Tw.font_bold ]
                               [ i [ Tw.px_1, Tw.pr_3, class "fab fa-discord" ] []
                               , text "Interested? Join our Discord!" ]
                      ]
                  ]
            , div [ Tw.absolute, Tw.bottom_5, Tw.right_5, Tw.flex, Tw.flex_row, Tw.space_x_1, Tw.rounded_xl, Tw.py_2, Tw.px_2, Tw.bg_gray_200, Tw.shadow_md ]
                  [ a [ href discordURL ] [ button (class "hover:bg-indigo-500 hover:text-white" :: buttonStyles) [ i [ Tw.px_1, class "fab fa-discord" ] [] ] ]
                  , a [ href githubURL ] [ button (class "hover:bg-gray-900 hover:text-white" :: buttonStyles) [ i [ Tw.px_1, class "fab fa-github" ] [] ] ]
                  ]
            ]
    }


buttonStyles =
    [ Tw.font_titillium, Tw.rounded_full, Tw.text_black, Tw.font_semibold, Tw.py_2, Tw.px_2, Tw.transform, Tw.transition, Tw.duration_300, Tw.ease_in_out ]


