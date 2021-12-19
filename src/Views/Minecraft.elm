module Views.Minecraft exposing (Model, Msg, init, toSession, view)

import Html exposing (Html, br, div, h1, h2, h3, h4, li, p, text, ul)
import Html.Attributes exposing (class)
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
    { title = "SMP Rules"
    , content =
        div [ Tw.bg_opacity_80, Tw.bg_gray_700, Tw.w_full, Tw.h_full, Tw.text_white, Tw.flex, Tw.flex_col ]
            [ div [ Tw.ml_16, Tw.mr_16 ]
                [ h1 [ Tw.text_6xl, class "montserrat", Tw.py_4, Tw.text_center ] [ text "SMP Rules" ]
                , h2 [ Tw.text_4xl, Tw.py_4, Tw.text_center ] [ text "Alongside our normal rules, the SMP has some additional rules" ]
                , h3 [ class "montserrat", Tw.text_2xl, Tw.py_2 ] [ text "Foreword" ]
                , p [ Tw.pl_10 ]
                    [ text "This server is meant to be a friendly SMP server. Be chill, respect others, don't do anything that would get you banned on 90% of servers and you'll be good. Don't annoy others and let them play on their own if they want to. That's really it."
                    , br [] []
                    , text "Keep in mind not everything can be made into a rule, and because of that we may occasionally punish players who didn't explicitly break any server rules, especially if they are destroying the fun of others. To combat trolling we prioritize the opinions of trusted, well-known and respected players."
                    ]
                , div [] (h3 [ class "montserrat", Tw.text_2xl, Tw.py_2 ] [ text "1. The Don't's:" ] :: dontRules)
                , div []
                    [ h3 [ class "montserrat", Tw.text_2xl, Tw.py_2 ] [ text "2. Modifications:" ]
                    , h4 [ class "montserrat" ] [ text "2.1. Allowed Modifications" ]
                    , allowedMods
                    , h4 [ class "montserrat" ] [ text "2.2 Allowed mod features (Mods that contain only these features should not get you banned):" ]
                    , allowedModFeatures
                    , h4 [ class "montserrat" ] [ text "2.3. Every mod not mentioned in 2.1 and every feature not mentioned in 2.2 is considered a \"use at your own risk\" (feel free to ask!)" ]
                    ]
                ]
            ]
    }


allowedModFeatures =
    ul [ Tw.list_disc, Tw.pl_10 ] <|
        List.map (text >> List.singleton >> li [])
            [ "Changing textures without adding transparency to them"
            , "Modifying game sound"
            , "Camera zoom"
            , "Maps that don't show you the positions of entities or the position of ores that are out of your sight"
            , "Changing the game menu"
            , "Displaying extra information on your screen (e.g. ping, saturation, armor, tool durability)"
            , "Changing the brightness of your game"
            , "Keybinds"
            , "Shaders"
            ]


allowedMods =
    ul [ Tw.list_disc, Tw.pl_10 ] <|
        List.map (text >> List.singleton >> li [])
            [ "Forge mod loader"
            , "Fabric mod loader with Fabric API"
            , "Optifine"
            , "Phosphor, Lithium, Sodium"
            , "Just Enough Items or any mod based on the same concept"
            , "Dynamic Lights or any mod based on the same concept"
            , "Mouse Tweaks"
            , "FoamFix"
            , "Client Tweaks"
            , "Dynamic FPS or any mod based on the same concept"
            , "ReAuth or any mod based on the same concept"
            , "Slight GUI Modifications"
            , "Light Overlay or any mod based on the same concept"
            ]


dontRules =
    List.map ruleElement
        [ "1.1. Spread bigotry and hate."
        , "1.2 Discriminate others on the basis of any personal trait, especially: ethnicity, gender, sexual orientation, age, religion and disability."
        , "1.3. Troll and annoy other players or server staff."
        , "1.4. Spread conspiracies and promote extremism."
        , "1.5. Start arguments and spread content with the intention of attracting negative responses."
        , "1.6. Spread personal information without consent."
        , "1.7. Insult and harass other players or server staff."
        , "1.8. Knowingly spread false information about players, staff or the server."
        , "1.9. Provoke others into breaking the rules."
        , "1.10. Use client modifications that give you an unfair advantage over other players. If you are unsure whether a certain modification is allowed, ask."
        , "1.11. Exploit bugs present in the game, especially ones that provide you an advantage over other players."
        , "1.12. Construct buildings that significantly affect server or client performance."
        , "1.13. Attempt to harm the server in any way."
        , "1.14. Advertise other minecraft servers, websites or services."
        , "1.15. Spam and flood the chat or server commands."
        , "1.16. Use an excessive amount of caps lock."
        , "1.17. Use an excessive amount of explicit or sexual language."
        , "1.18. Spread controversial or pornographic content."
        , "1.19. Destroy other player's buildings (note that raiding is allowed AS LONG AS the area is not claimed)"
        , "1.20. Construct buildings with the intention to disfigure terrain."
        , "1.21. Bypass punishments."
        , "1.22. Ignore server staff orders."
        ]


ruleElement =
    p [ Tw.pl_10 ] << (List.singleton << text)


toSession =
    .session
