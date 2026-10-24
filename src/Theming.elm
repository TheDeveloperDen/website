module Theming exposing (Accent(..), accentColour, badgeStyle, bodyFont, brandGradientBg, cardShell, entityIcon, gradientButton, gutter, headingFont, pageTitle, prose, quietLink, themedImage)

import Css
import Css.Global as Global
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import LearningResources
import LearningResources.Emojis as Emojis
import LearningResources.Types exposing (CompiledMeta)
import Tailwind.Breakpoints as Breakpoints
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw


brandGradient : String
brandGradient =
    "linear-gradient(to right, var(--color-den-teal), var(--color-den-indigo), var(--color-den-pink))"


brandGradientBg : Css.Style
brandGradientBg =
    -- elm tailwind doesnt seem to play well with this
    Css.property "background-image" brandGradient


{-| The brand gradient made to render as an underline of some text
-}
gradientUnderline : Css.Style
gradientUnderline =
    Css.batch
        [ brandGradientBg
        , Css.property "background-size" "100% 4px"
        , Css.property "background-repeat" "no-repeat"
        , Css.property "background-position" "bottom left"
        ]


headingFont : Css.Style
headingFont =
    Css.batch [ Tw.font_mono, Tw.text_color Tw.dd_text ]


bodyFont : Css.Style
bodyFont =
    Css.batch [ Tw.font_sans, Tw.font_medium, Tw.text_color Tw.dd_muted ]


{-| Lowercase Cascadia Code left-aligned title with the gradient underline.
-}
pageTitle : String -> Html msg
pageTitle title =
    Html.h1
        [ Attr.css
            [ headingFont
            , Tw.text_4xl
            , Breakpoints.md [ Tw.text_5xl ]
            , Tw.font_semibold
            , Tw.lowercase
            , Tw.inline_block
            , Tw.pb_3
            , Tw.m_0
            , gradientUnderline
            ]
        ]
        [ Html.text title ]


{-| A large button outlined with the brand gradient on the deep-blue background ground.
-}
gradientButton : Css.Style
gradientButton =
    let
        layers : String -> String
        layers fill =
            "linear-gradient(" ++ fill ++ ", " ++ fill ++ ") padding-box, " ++ brandGradient ++ " border-box"
    in
    Css.batch
        [ headingFont
        , Tw.text_lg
        , Tw.font_semibold
        , Tw.px_8
        , Tw.py_4
        , Tw.border_2
        , Tw.border_color Tw.transparent
        , Tw.no_underline
        , Tw.inline_flex
        , Tw.items_center
        , Tw.justify_center
        , Tw.gap_3
        , Css.property "background" (layers "var(--color-den-deepblue)")
        , Css.hover [ Css.property "background" (layers "var(--color-den-deepblue-lighter)") ]
        ]


{-| Muted text that brightens on hover, for navigation-style links and buttons.
-}
quietLink : Css.Style
quietLink =
    Css.batch
        [ Tw.text_color Tw.dd_subtle
        , Css.hover [ Tw.text_color Tw.dd_text ]
        , Tw.transition_colors
        , Tw.no_underline
        ]


{-| Side padding shared by every page container, so content lines up with the navbar at every width.
-}
gutter : Css.Style
gutter =
    Css.batch [ Tw.px_5, Breakpoints.md [ Tw.px_8 ] ]


{-| An image with dark and light variants.
-}
themedImage : { dark : String, light : String, alt : String } -> List Css.Style -> List (Html msg)
themedImage config styles =
    let
        image : String -> Html msg
        image src =
            Html.img [ Attr.src src, Attr.alt config.alt, Attr.css styles ] []
    in
    [ Html.span [ Attr.class "on-dark" ] [ image config.dark ]
    , Html.span [ Attr.class "on-light" ] [ image config.light ]
    ]


{-| A topic's icon at the given size, picking the dark variant on dark backgrounds. Uses the emoji if there's no icon defined
-}
entityIcon : Css.Style -> CompiledMeta -> Html msg
entityIcon size meta =
    case meta.icon of
        Just icon ->
            Html.span [ Attr.css [ Css.display Css.inlineFlex, Css.flexShrink (Css.int 0) ] ]
                (themedImage
                    { dark = LearningResources.iconUrl (Maybe.withDefault icon.default icon.dark)
                    , light = LearningResources.iconUrl icon.default
                    , alt = ""
                    }
                    [ size, Css.property "object-fit" "contain" ]
                )

        Nothing ->
            Html.span [ Attr.css [ size ] ] [ Html.text (Emojis.emojiOrBackup meta) ]


type Accent
    = Teal
    | Indigo
    | Pink


accentColour : Accent -> Tw.Color
accentColour accent =
    case accent of
        Teal ->
            Tw.dd_teal

        Indigo ->
            Tw.dd_indigo

        Pink ->
            Tw.dd_pink


accentVar : Accent -> String
accentVar accent =
    case accent of
        Teal ->
            "--color-den-teal"

        Indigo ->
            "--color-den-indigo"

        Pink ->
            "--color-den-pink"


badgeStyle : Accent -> Css.Style
badgeStyle accent =
    let
        colourVar : String
        colourVar =
            accentVar accent
    in
    Css.batch
        [ Css.property "color" ("var(" ++ colourVar ++ ")")
        , Css.property "background-color" ("color-mix(in srgb, var(" ++ colourVar ++ ") 14%, transparent)")
        , Css.property "border" ("1px solid color-mix(in srgb, var(" ++ colourVar ++ ") 35%, transparent)")
        ]


cardShell : List Css.Style -> List (Html msg) -> Html msg
cardShell extraStyles children =
    Html.div
        [ Attr.css
            ([ Tw.bg_color Tw.dd_deepblueLighter
             , Tw.border
             , Tw.border_color Tw.dd_border
             ]
                ++ extraStyles
            )
        ]
        children


{-| Styles for rendered Markdown for blog posts
Code blocks are highlighted in the browser by Shiki (`public/highlight-init.js`), 
-- we set the colour `--shiki-*` variables here so they follow the theming
-}
prose : Css.Style
prose =
    Css.batch
        [ Tw.text_lg
        , Tw.leading_7
        , syntaxHighlightingColours
        , Global.descendants
            [ Global.each [ Global.typeSelector "h2", Global.typeSelector "h3" ]
                [ Tw.font_semibold, Tw.mt_12, Tw.mb_5, Tw.leading_snug ]
            , Global.typeSelector "h2" [ Tw.text_3xl ]
            , Global.typeSelector "h3" [ Tw.text_2xl ]
            , Global.each [ Global.typeSelector "p", Global.typeSelector "ul", Global.typeSelector "ol", Global.typeSelector "pre", Global.typeSelector "blockquote", Global.typeSelector "table" ]
                [ Tw.m_0, Tw.mb_7 ]
            , Global.typeSelector "li" [ Tw.mb_1 ]
            , Global.each [ Global.typeSelector "ul", Global.typeSelector "ol" ] [ Tw.pl_6 ]
            , Global.typeSelector "a" [ Tw.text_color Tw.dd_teal ]
            , Global.typeSelector "blockquote" [ Tw.border_l_4, Tw.border_color Tw.dd_indigo, Tw.pl_6, Tw.text_color Tw.dd_muted ]
            , Global.typeSelector "code" [ Tw.font_mono, Tw.text_base, Tw.bg_color Tw.dd_deepblueLighter, Tw.px_1 ]
            , Global.typeSelector "pre" [ Tw.bg_color Tw.dd_deepblueLighter, Tw.border, Tw.border_color Tw.dd_border, Tw.px_6, Tw.py_5, Tw.overflow_x_auto ]
            , Global.selector "pre code" [ Tw.bg_color Tw.transparent, Tw.p_0 ]
            , Global.typeSelector "img" [ Tw.max_w_full, Tw.h_auto ]

            -- use block display so a wide table scrolls instead of widening the page
            , Global.typeSelector "table" [ Tw.block, Tw.overflow_x_auto, Tw.border_collapse ]
            , Global.each [ Global.typeSelector "th", Global.typeSelector "td" ] [ Tw.border, Tw.border_color Tw.dd_border, Tw.px_3, Tw.py_2, Tw.text_left ]
            , Global.typeSelector "hr" [ Tw.border_0, Tw.border_t, Tw.border_color Tw.dd_border, Tw.my_12 ]
            ]
        , Global.children [ Global.everything [ Css.lastChild [ Tw.mb_0 ] ] ]
        ]


syntaxHighlightingColours : Css.Style
syntaxHighlightingColours =
    Css.batch
        ([ ( "foreground", "text" )
         , ( "background", "deepblue-lighter" )
         , ( "token-keyword", "pink" )
         , ( "token-function", "indigo" )
         , ( "token-constant", "indigo" )
         , ( "token-string", "teal" )
         , ( "token-string-expression", "teal" )
         , ( "token-comment", "subtle" )
         , ( "token-parameter", "muted" )
         , ( "token-punctuation", "muted" )
         , ( "token-link", "teal" )
         ]
            |> List.map (\( name, colour ) -> Css.property ("--shiki-" ++ name) ("var(--color-den-" ++ colour ++ ")"))
        )
