module Views.ServicesRules exposing (Model, Msg, view)

import Browser.Navigation as Nav
import Html exposing (Html, a, b, div, h1, h2, h3, i, li, p, text, ul)
import Html.Attributes exposing (class, href)
import Redirects exposing (freeServicesURL, paidServicesURL)
import Tailwind as Tw


type alias Model =
    { key : Nav.Key
    }


type alias Msg =
    ()


view : Model -> { title : String, content : Html Msg }
view _ =
    { title = "Services Rules"
    , content =
        div [ Tw.bg_opacity_80, Tw.bg_gray_700, Tw.w_full, Tw.flex_1, Tw.text_white, Tw.flex, Tw.flex_col ]
            [ div [ Tw.ml_16, Tw.mr_16, Tw.mb_20 ]
                [ h1 [ Tw.text_6xl, class "montserrat", Tw.mt_2, Tw.py_2, Tw.text_center ] [ text "Services Rules" ]
                , h2 [ Tw.text_2xl, Tw.py_2, Tw.font_titillium, Tw.text_center ] [ text "Rules for posting in ", inlineLink "#💰-paid-services" paidServicesURL, text " and ", inlineLink "🆓-free-services" freeServicesURL ]
                , ruleHeader "Global Rules"
                , rulesList
                    [ i [] [ text "In all rules, the term 'host' refers to someone offering their services and the term 'client' refers to anyone seeking the services of a host." ]
                    , text "Only active members (Tier 3+) may create posts in these channels to reduce spam and abuse."
                    , text "All service offers (free and paid) may only be posted by individuals representing themselves. Organizations such as service teams are not allowed to offer services, but may respond to requests privately."
                    , text "Posts should be appropriately tagged to describe the service(s)."
                    , text "Posts should include a title concisely describing the host (if applicable) and/or the service(s)."
                    , text "Only 1 post per service may be made per month."
                    , text "Anyone may respond to a post (there are no activity requirements). This should be done in Direct Messages (or any other contact method described in the post), not as replies to a thread."
                    , text "Hosts have no obligation to accept work offered by a client, and vice versa."
                    , text "It is the host's responsibility to ensure that their clients are trustworthy."
                    , text "Similarly, it is the client's responsibility to ensure the host is the right choice for their needs."
                    , text "The Developer Den has no obligation to investigate or take action in the case of scams or disputes. We will attempt to do so if possible, but no action is guaranteed."
                    , text "To request an investigation please send a message to @ModMail#5460 in the Discord Server"
                    ]
                , ruleHeader "Paid Services"
                , rulesList
                    [ i [] [ text "These rules only apply to ", inlineLink "#💰-paid-services" paidServicesURL, text "." ]
                    , div []
                        [ text "This channel is for offering or requesting "
                        , b [] [ text "paid" ]
                        , text " services."
                        ]
                    , text "Posts must include a price / maximum budget, which should be in $USD. Hosts may choose to offer quote-by-quote prices available after conferring with the client."
                    , text "Budgets / payments must be a concrete amount, not something like \"10% of profits\"."
                    , text "The Developer Den's only role is as a platform for finding clients / hosts. We do not act as a middleman for any funds except in exceptional circumstances."
                    ]
                , ruleHeader "Free Services"
                , rulesList
                    [ i [] [ text "These rules only apply to ", inlineLink "🆓-free-services" freeServicesURL, text "." ]
                    , div []
                        [ text "This channel is only for "
                        , b [] [ text "offering" ]
                        , text " free services. To reduce spam, free requests are not allowed"
                        ]
                    , text "Hosts or clients from this channel must not request any money for work. Optional donations are permitted, but they must be optional."
                    , text "As work in this channel is free, scams are far less likely. However, to request an investigation please DM @ModMail#5460 in the Discord Server"
                    ]
                ]
            ]
    }


ruleHeader body =
    h3 [ class "montserrat", Tw.text_2xl, Tw.py_2, Tw.mt_2 ] [ text body ]


rulesList : List (Html Msg) -> Html Msg
rulesList rules =
    ul [ Tw.space_y_1, Tw.list_disc ] (List.map (ruleLine << List.singleton) rules)


ruleLine : List (Html Msg) -> Html Msg
ruleLine text =
    li [ Tw.ml_8 ] [ p [ Tw.font_titillium, Tw.text_lg ] text ]


inlineLink : String -> String -> Html Msg
inlineLink val link =
    a [ Tw.text_indigo_300, Tw.underline, Tw.hover__text_blue_500, Tw.duration_300, Tw.ease_in_out, href link ] [ text val ]
