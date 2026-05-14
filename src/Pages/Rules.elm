module Pages.Rules exposing (Model, Msg, page)

import Css
import Effect exposing (Effect)
import Html.Styled as Html exposing (Html, a, div, h1, h2, h3, p, span, text)
import Html.Styled.Attributes as Attr exposing (css)
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw
import Theming
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
        |> Page.withLayout
            (\_ ->
                Layouts.Global
                    { activePage = Route.Path.Rules
                    }
            )



-- INIT


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init () =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = NoOp


type alias RuleSection =
    { id : Int
    , title : String
    , rules : List (List (Html Msg))
    }


rulesData : List RuleSection
rulesData =
    [ { id = 1
      , title = "Conduct and Communication"
      , rules =
            [ [ Html.b [ css [ Tw.text_color Tw.white ] ] [ text "Respect the Community: " ]
              , text "No rudeness, insults, harassment, or \"dogpiling\" (ganging up on someone)."
              ]
            , [ Html.b [ css [ Tw.text_color Tw.white ] ] [ text "Engage in good faith: " ]
              , text "No intentional derailing, \"sealioning\" (disingenuous questions), extreme sarcasm, or ragebait. Keep debates respectful and fair."
              ]
            , [ Html.b [ css [ Tw.text_color Tw.white ] ] [ text "Keep Criticism Constructive: " ]
              , text "Stay objective about code/tools. No flaming, elitism, or mocking others for their choices, especially beginners."
              ]
            ]
      }
    , { id = 2
      , title = "Moderation Protocols"
      , rules =
            [ [ Html.b [ css [ Tw.text_color Tw.white ] ] [ text "No public moderation disputes: " ]
              , text "Do not argue about warnings, mutes, or deleted messages in public. Mocking or undermining staff instructions leads to immediate escalation."
              ]
            , [ Html.b [ css [ Tw.text_color Tw.white ] ] [ text "Official Channels: " ]
              , text "DM @Modmail to open a ticket for moderation issues."
              ]
            , [ Html.b [ css [ Tw.text_color Tw.white ] ] [ text "Staff Discretion: " ]
              , text "Staff may remove users who are a net negative to the community vibe, even without a specific rule break."
              ]
            ]
      }
    , { id = 3
      , title = "Sensitive Content & Personal Boundaries"
      , rules =
            [ [ Html.b [ css [ Tw.text_color Tw.white ] ] [ text "No trauma-dumping: " ]
              , text "Keep sensitive personal topics (mental health, self-harm, politics) out of public channels."
              ]
            , [ Html.b [ css [ Tw.text_color Tw.white ] ] [ text "No Vigilante Justice / Minimodding: " ]
              , text "Report rule-breakers. Do not act as a moderator or take it upon yourself to \"teach them a lesson.\""
              ]
            ]
      }
    , { id = 4
      , title = "Help Us Help You"
      , rules =
            [ [ text "Just ask your question, ", inlineLink "don't ask to ask, just ask" "https://dontasktoask.com" ]
            , [ text "Give as much information as possible when asking for help." ]
            , [ text "Don't DM or ping random people / staff for help, just ask your question and be patient." ]
            , [ text "Use a ", inlineLink "paste service" "https://paste.developerden.org", text " for large blocks of code." ]
            ]
      }
    , { id = 5
      , title = "Don't Be Evil"
      , rules =
            [ [ text "No NSFW content. Keep language reasonable with no excessive swearing." ]
            , [ text "Follow Discord's Terms of Service." ]
            , [ text "No spam, self-promotion, or harmful links." ]
            , [ text "No asking for help with illegal/malicious programs." ]
            , [ text "Other ethical violations like asking people to do your schoolwork for you are not allowed." ]
            ]
      }
    ]


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Rules"
    , body =
        [ div [ css [ Tw.max_w_4xl, Tw.mx_auto, Tw.pt_2, Tw.pb_24, Tw.px_6 ] ]
            [ viewHeader
            , div []
                (List.map viewRuleSection rulesData)
            ]
        ]
    }


viewHeader : Html Msg
viewHeader =
    div [ css [ Tw.mb_8, Tw.text_center ] ]
        [ h1
            [ css
                [ Theming.headingFont
                , Tw.text_5xl
                , Tw.font_bold
                , Tw.mb_2
                , Theming.textGradient
                , Tw.inline_block
                ]
            ]
            [ text "Server Rules" ]
        , h2
            [ css [ Theming.bodyFont, Tw.text_lg, Tw.text_color Tw.gray_300 ] ]
            [ text "You are welcome in our community as long as you follow the rules." ]
        ]


viewRuleSection : RuleSection -> Html Msg
viewRuleSection section =
    div
        [ css
            [ Tw.mb_6 ]
        ]
        [ h3
            [ css [ Theming.headingFont, Tw.text_2xl, Tw.text_color Tw.dd_teal, Tw.mb_3 ] ]
            [ text (String.fromInt section.id ++ ". " ++ section.title) ]
        , div [ css [ Tw.flex, Tw.flex_col, Tw.gap_2] ]
            (List.indexedMap viewRuleLine section.rules)
        ]


viewRuleLine : Int -> List (Html Msg) -> Html Msg
viewRuleLine index content =
    let
        -- convert 0, 1, 2 into 'a', 'b', 'c'
        letter =
            String.fromChar (Char.fromCode (97 + index)) ++ ". "
    in
    p 
        [ css 
            [ Theming.bodyFont
            , Tw.text_base
            , Tw.text_color Tw.gray_300
            , Tw.leading_snug
            , Tw.m_0 
            ] 
        ]
        (Html.text letter :: content)


inlineLink : String -> String -> Html Msg
inlineLink val url =
    a
        [ Attr.href url
        , Attr.target "_blank"
        , css
            [ Tw.text_color Tw.dd_pink
            , Tw.font_semibold
            , Tw.no_underline
            , Css.hover [ Tw.text_color Tw.white ]
            , Tw.transition_colors
            ]
        ]
        [ text val ]
