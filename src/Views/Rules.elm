module Views.Rules exposing (Model, Msg, init, toSession, view)

import Html exposing (Html, a, b, div, h1, h2, h3, p, text)
import Html.Attributes exposing (href)
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
        div [ Tw.bg_opacity_80, Tw.bg_gray_700, Tw.w_full, Tw.text_white, Tw.flex, Tw.flex_col, Tw.object_contain ]
            [ h1 [ Tw.text_6xl, Tw.underline, Tw.py_4 ] [ text "Server Rules" ]
            , h2 [ Tw.text_4xl, Tw.py_4 ] [ text "You are welcome in our community so long as you follow the rules" ]
            , h3 [ Tw.text_2xl, Tw.py_2 ] [ text "1. Be respectful" ]
            , p [ Tw.pl_16 ]
                [ text "We are all here to help each other, so please be respectful of each other. Rude or discriminatory language of any kind will not be tolerated" ]
            , h3 [ Tw.text_2xl, Tw.py_2 ] [ text "2. Be patient" ]
            , p [ Tw.pl_16 ] [ text "Just ask your question, don't", a [ Tw.underline, href "https://dontasktoask.com/" ] [ text " ask to ask, just ask." ] ]
            , p [ Tw.pl_16 ] [ text "Don't ping or DM random people / staff for help" ]
            , h3 [ Tw.text_2xl, Tw.py_2 ] [ text "3. Use the right channels" ]
            , p [ Tw.pl_16 ] [ text "Keep discussion of controversial subjects to ", a [ href "https://discord.com/channels/821743100203368458/851563025190223913" ] [ text "#📋-serious-discussions." ] ]
            , p [ Tw.pl_16 ] [ text "If on-topic conversations are being interrupted, move channel." ]
            , h3 [ Tw.text_2xl, Tw.py_2 ] [ text "4. Don't be annoying" ]
            , p [ Tw.pl_16 ] [ text "Don't spam, self-promote or send harmful links and programs." ]
            , p [ Tw.pl_16 ] [ text "Asking for help with illegal or malicious tools or programs is strictly forbidden." ]
            , p [ Tw.pl_16 ] [ text "This server is ", b [] [ text "not" ], text " a marketplace to get development services, paid or free." ]
            , p [ Tw.pl_16 ] [ text "If you need to send large blocks of code, use a ", a [ href "http://paste.developerden.net/", Tw.underline ] [ text "paste service" ] ]
            , h3 [ Tw.text_2xl, Tw.py_2 ] [ text "5. Other stuff" ]
            , p [ Tw.pl_16 ] [ text "Staff reserve the right to punish users even if they haven't explicitly broken any rules, but are deemed to be annoying or hurting the server." ]
            , p [ Tw.pl_16 ] [ text "Channels like ", a [ href "https://discord.com/channels/821743100203368458/847936633964724254" ] [ text "#💫-showcase" ], text " have their own specific rules in a pinned message, make sure to read those before posting." ]
            ]
    }


toSession =
    .session
