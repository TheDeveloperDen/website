module Route.Rules exposing (ActionData, Data, Model, Msg, route)

import BackendTask
import Css
import Head
import Head.Seo as Seo
import Html.Styled as Html exposing (Html, a, div, h2, h3, p, text)
import Html.Styled.Attributes as Attr exposing (css)
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw
import Tailwind.Breakpoints as Breakpoints
import Theming
import UrlPath
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    ()


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = BackendTask.succeed ()
        }
        |> RouteBuilder.buildNoState { view = view }


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "Developer Den"
        , image =
            { url = UrlPath.fromString "devden-banner.svg" |> Pages.Url.fromPath
            , alt = "Developer Den"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "The rules of the Developer Den community."
        , locale = Nothing
        , title = "Rules"
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromStyled "Rules" [ div [ css [ Tw.max_w_7xl, Tw.mx_auto, Tw.w_full, Tw.pt_12, Tw.pb_24, Theming.gutter ] ] [ viewHeader, div [] (List.map viewRuleSection rulesData) ] ]
        |> View.map PagesMsg.fromMsg


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
            [ [ Html.b [ css [ Tw.text_color Tw.dd_text ] ] [ text "Respect the Community: " ]
              , text "No rudeness, insults, harassment, or \"dogpiling\" (ganging up on someone)."
              ]
            , [ Html.b [ css [ Tw.text_color Tw.dd_text ] ] [ text "Engage in good faith: " ]
              , text "No intentional derailing, \"sealioning\" (disingenuous questions), extreme sarcasm, or ragebait. Keep debates respectful and fair."
              ]
            , [ Html.b [ css [ Tw.text_color Tw.dd_text ] ] [ text "Keep Criticism Constructive: " ]
              , text "Stay objective about code/tools. No flaming, elitism, or mocking others for their choices, especially beginners."
              ]
            ]
      }
    , { id = 2
      , title = "Moderation Protocols"
      , rules =
            [ [ Html.b [ css [ Tw.text_color Tw.dd_text ] ] [ text "No public moderation disputes: " ]
              , text "Do not argue about warnings, mutes, or deleted messages in public. Mocking or undermining staff instructions leads to immediate escalation."
              ]
            , [ Html.b [ css [ Tw.text_color Tw.dd_text ] ] [ text "Official Channels: " ]
              , text "DM @Modmail to open a ticket for moderation issues."
              ]
            , [ Html.b [ css [ Tw.text_color Tw.dd_text ] ] [ text "Staff Discretion: " ]
              , text "Staff may remove users who are a net negative to the community vibe, even without a specific rule break."
              ]
            ]
      }
    , { id = 3
      , title = "Sensitive Content & Personal Boundaries"
      , rules =
            [ [ Html.b [ css [ Tw.text_color Tw.dd_text ] ] [ text "No trauma-dumping: " ]
              , text "Keep sensitive personal topics (mental health, self-harm, politics) out of public channels."
              ]
            , [ Html.b [ css [ Tw.text_color Tw.dd_text ] ] [ text "No Vigilante Justice / Minimodding: " ]
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


viewHeader : Html Msg
viewHeader =
    div [ css [ Tw.mb_10 ] ]
        [ div [ css [ Tw.mb_6 ] ] [ Theming.pageTitle "server rules" ]
        , h2
            [ css [ Theming.bodyFont, Tw.text_lg, Tw.m_0 ] ]
            [ text "You are welcome in our community as long as you follow the rules." ]
        ]


viewRuleSection : RuleSection -> Html Msg
viewRuleSection section =
    div
        [ css
            [ Tw.border_t
            , Tw.border_color Tw.dd_border
            , Tw.py_8
            , Tw.flex
            , Tw.flex_col
            , Tw.gap_4
            , Breakpoints.md [ Tw.flex_row, Tw.gap_12 ]
            ]
        ]
        [ h3
            [ css [ Theming.headingFont, Tw.text_xl, Tw.font_semibold, Tw.m_0, Tw.flex_shrink_0, Breakpoints.md [ Tw.w_72 ] ] ]
            [ Html.span [ css [ Tw.text_color Tw.dd_subtle ] ] [ text (String.fromInt section.id ++ ". ") ]
            , text section.title
            ]
        , div [ css [ Tw.flex, Tw.flex_col, Tw.gap_3, Tw.max_w_2xl ] ]
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
            [ Tw.text_color Tw.dd_indigo
            , Tw.font_semibold
            , Tw.no_underline
            , Css.hover [ Tw.text_color Tw.dd_pink ]
            , Tw.transition_colors
            ]
        ]
        [ text val ]
