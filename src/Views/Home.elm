module Views.Home exposing (Model, Msg, view)

import Browser.Navigation as Nav
import Html exposing (Attribute, Html, a, button, div, fieldset, h1, h2, i, legend, p, text)
import Html.Attributes exposing (class, href, src)
import Redirects exposing (discordURL, githubURL)
import Tailwind as Tw


type alias Model =
    ()


type alias Msg =
    ()


view : Model -> { title : String, content : Html Msg }
view _ =
    { title = "Home"
    , content =
        div [ Tw.flex, Tw.flex_col, Tw.my_auto, Tw.h_auto, Tw.items_center, Tw.justify_center, Tw.text_white ]
            [ Html.img [ src "devden_logo.svg", Tw.max_w_7xl, Tw.pb_10 ] []
            , h2 [ Tw.text_center, Tw.font_montserrat, Tw.text_3xl, Tw.py_4 ] [ text "A closely-knit community anchored in a common passion for programming." ]
            , div [ Tw.py_7 ]
                [ a [ href discordURL, Tw.bg_indigo, Tw.text_2xl, Tw.p_5, Tw.rounded_2xl, Tw.shadow_md, Tw.ease_in_out, Tw.duration_300 ]
                    [ button [ Tw.font_cascadia, Tw.font_bold ]
                        [ i [ Tw.px_1, Tw.pr_3, class "fab fa-discord" ] []
                        , text "Interested? Join our Discord!"
                        ]
                    ]
                ]
            , div [ Tw.inline_flex, Tw.flex_row, Tw.ml_5, Tw.mt_5 ]
                [ projectOf [] "web frontend" "the frontend website that you're viewing now that is written in elm and tailwind css" "https://github.com/TheDeveloperDen/devden-web-frontend"
                , projectOf [] "discord bot" "the discord bot that manages many aspects of our discord server (ex. xp, leaderboards)" "https://github.com/TheDeveloperDen/DevDenBot"
                , projectOf [] "learning resources" "a repository containing crowd-sourced information on how to learn different languages" "https://github.com/TheDeveloperDen/LearningResources"
                ]
            , div [ Tw.absolute, Tw.bottom_5, Tw.right_5, Tw.flex, Tw.flex_row, Tw.space_x_1, Tw.rounded_xl, Tw.py_2, Tw.px_2, Tw.bg_gray_200, Tw.shadow_md ]
                [ a [ href discordURL ] [ button (class "hover:bg-indigo-500 hover:text-white" :: buttonStyles) [ i [ Tw.px_1, class "fab fa-discord" ] [] ] ]
                , a [ href githubURL ] [ button (class "hover:bg-gray-900 hover:text-white" :: buttonStyles) [ i [ Tw.px_1, class "fab fa-github" ] [] ] ]
                ]
            ]
    }


projectOf : List (Attribute Msg) -> String -> String -> String -> Html Msg
projectOf attr name desc url =
    div attr
        [ fieldset [ Tw.p_3, Tw.border_gray_300, Tw.border_2, Tw.border_opacity_50, Tw.m_5, Tw.rounded_2xl, Tw.shadow_md, Tw.w_auto ]
            [ legend [ Tw.px_1_dot_5, Tw.py_0, Tw.hover__bg_gray_200, Tw.rounded_2xl, Tw.duration_300, Tw.ease_in_out ]
                [ a [ href url, Tw.font_cascadia, Tw.font_bold, Tw.hover__text_black, Tw.p_0_dot_5, Tw.duration_300, Tw.ease_in_out ] [ text name ] ]
            , p [ Tw.font_montserrat, Tw.break_words ] [ text desc ]
            ]
        ]


buttonStyles =
    [ Tw.font_montserrat, Tw.rounded_full, Tw.text_black, Tw.font_semibold, Tw.py_2, Tw.px_2, Tw.transform, Tw.transition, Tw.duration_300, Tw.ease_in_out ]
