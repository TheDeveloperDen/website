module Views.Rules exposing (Model, Msg, init, toSession, view)

import Html exposing (Html, a, div, h1, h2, h3, h4, text)
import Html.Attributes exposing (class, href)
import Session exposing (Session)
import Tailwind as Tw


type alias Model =
    { session : Session
    }


type alias Msg =
    ()


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session }
    , Cmd.none
    )


view : Model -> { title : String, content : Html Msg }
view _ =
    { title = "Rules"
    , content =
        div [ Tw.bg_opacity_80, Tw.bg_gray_700, Tw.w_full, Tw.flex_1, Tw.text_white, Tw.flex, Tw.flex_col ]
            [ div [ Tw.ml_16, Tw.mr_16 ]
                [ h1 [ Tw.text_6xl, class "montserrat", Tw.py_2, Tw.text_center ] [ text "Server Rules" ]
                , h2 [ Tw.text_3xl, Tw.py_2, class "montserrat", Tw.text_center ] [ text "You are welcome in our community as long as you follow the rules." ]
                , ruleHeader "1. Be Nice"
                , ruleLine [ text "a. Don't be rude or disrespectful to anyone in the server." ]
                , ruleLine [ text "b. Criticism should be constructive. Nitpicking, flaming a certain programming language, etc doesn't help anyone." ]
                , ruleHeader "2. Help us to help you"
                , ruleLine [ text "a. Just ask your question, don't ", a [ Tw.underline, href "https://dontasktoask.com/" ] [ text "ask to ask, just ask" ], text "." ]
                , ruleLine [ text "b. Give as much information as possible when asking for help." ]
                , ruleLine [ text "c. Don't DM or ping random people / staff for help, just ask your question and be patient." ]
                , ruleLine [ text "d. If you need to send large blocks of code, please use a ", a [ Tw.underline, href "http://paste.developerden.net/" ] [ text "paste service" ], text "." ]
                , ruleHeader "3. Don't be evil"
                , ruleLine [ text "a. NSFW content is not allowed. Swearing is fine, but keep it PG13." ]
                , ruleLine [ text "b. Follow Discord's Terms of Service." ]
                , ruleLine [ text "c. Don't spam, self-promote or send harmful links or programs in public channels or DMs." ]
                , ruleLine [ text "d. Asking for help with illegal or malicious programs is strictly forbidden." ]
                , ruleLine [ text "e. Other unethical questions such as asking people to do your schoolwork are not allowed." ]
                , ruleHeader "4. Stay on topic & use the right channels"
                , ruleLine [ text "a. If on-topic conversations are being interrupted by off-topic ones, move to a more relevant channel or make a thread." ]
                , ruleLine [ text "b. Controversial / sensitive content (politics, religion, mental health, etc) should only be discussed in ", a [ Tw.font_bold, href "https://discord.com/channels/821743100203368458/851563025190223913" ] [ text "#📋-serious-discussions." ] ]
                , ruleLine [ text "c. Try to keep shitposts to ", a [ Tw.font_bold, href "https://discord.com/channels/821743100203368458/932661343520194640" ] [ text "#🌞-random" ], text " as much as possible." ]
                , ruleLine [ text "d. You can share things you've made in ", a [ Tw.font_bold, href "https://discord.com/channels/821743100203368458/847936633964724254" ] [ text "#💫-showcase" ], text " (read the pinned message before posting)." ]
                , ruleHeader "5. Other Stuff"
                , ruleLine [ text "a. Hiring freelancers & offering services is currently not permitted." ]
                , ruleLine [ text "b. Don't minimod." ]
                , ruleLine [ text "c. Don't try and find loopholes in rules." ]
                , ruleLine [ text "d. Staff reserve the right to punish anyone even if they haven't explicitly broken any rules." ]
                ]
            ]
    }


ruleHeader body =
    h3 [ class "montserrat", Tw.text_2xl, Tw.py_2, Tw.mt_2 ] [ text body ]


ruleLine text =
    h4 [ Tw.pl_8, Tw.font_mono ] text


toSession =
    .session
