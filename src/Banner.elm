module Banner exposing (Banner, seoImage, toSvg)

{-| Renders the social preview image ("banner") for a page, as an SVG string. Its size is `layout.canvas`.

The layout is, from top to bottom on the left: the Developer Den logo, a small subtitle (such as "learn" or "welcome to"),
the big title with a coloured underline, and a tagline. Pages about a topic can also have the topic's icon on the right.

@docs Banner, seoImage, toSvg

-}

import Base64
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes
import MimeType
import Pages.Url
import Svg exposing (Svg)
import Svg.Attributes exposing (fill, fontFamily, fontSize, fontWeight, height, id, offset, rx, stopColor, stroke, strokeLinejoin, strokeWidth, viewBox, width, x, x1, x2, y, y1, y2)
import UrlPath


{-| The text and images that go on one banner.
-}
type alias Banner =
    { subtitle : String
    , title : String
    , tagline : String

    -- The Developer Den logo, as SVG source text.
    , logo : String

    -- The topic's icon as SVG source text, or 'Nothing' for pages without one such as the home page.
    , icon : Maybe String
    }


{-| Every colour on the banner.
-}
colours :
    { background : String
    , tile : String
    , accent : String
    , title : String
    , tagline : String
    , gradientStart : String
    , gradientEnd : String
    }
colours =
    { background = "#171834"
    , tile = "#1f2147"
    , accent = "#8099FF"
    , title = "#ffffff"
    , tagline = "#c9cbf0"
    , gradientStart = "#00AFC3"
    , gradientEnd = "#FF52F9"
    }


type alias TextStyle =
    { font : String
    , weight : Int
    , colour : String
    , lineSpacing : Float
    , charWidth : Float
    }


titleStyle : TextStyle
titleStyle =
    { font = "Cascadia Code", weight = 600, colour = colours.title, lineSpacing = 1.15, charWidth = 0.6 }


subtitleStyle : TextStyle
subtitleStyle =
    { titleStyle | colour = colours.accent }


taglineStyle : TextStyle
taglineStyle =
    { font = "Montserrat", weight = 500, colour = colours.tagline, lineSpacing = 1.35, charWidth = 0.6 }


{-| The biggest and smallest font sizes the title and tagline can shrink between to fit (see `fontSizes`), and how many
lines the title may take.
-}
titleFit : { largest : Float, smallest : Float, maxLines : Int }
titleFit =
    { largest = 120, smallest = 60, maxLines = 2 }


taglineFit : { largest : Float, smallest : Float }
taglineFit =
    { largest = 34, smallest = 21 }


{-| Produce a list of possible font sizes to try, in size order.
-}
fontSizes : { a | largest : Float, smallest : Float } -> List Float
fontSizes { largest, smallest } =
    let
        steps : Int
        steps =
            4

        ratio : Float
        ratio =
            (smallest / largest) ^ (1 / toFloat steps)
    in
    List.range 0 steps |> List.map (\step -> toFloat (round (largest * ratio ^ toFloat step)))


{-| The measurements of the underline under the title, measured in percentages of the main font size.

  - `offset`: the space between the bottom of the letters and the top of the underline.
  - `thickness`: how thick the underline is.
  - `leftPad`: Left padding size. This exists because if the first letter has a tail (e.g. `g`), the gap cut around the tail leaves a thin sliver of underline on its left.
  - `descenderGap`: the total width of the gap cut in the underline around letters with tails, such as `p` and `y`, distributed evenly on each side.

These aren't perfectly accurate because they're mostly eyeballed (sorry)

-}
underlineStyle : { offset : Float, thickness : Float, leftPad : Float, descenderGap : Float }
underlineStyle =
    { offset = 0.13, thickness = 0.107, leftPad = 0.05, descenderGap = 0.16 }


{-| Global pixel measurements for most things

  - `canvas`: the size of the whole image.
  - `margin`: on both sides
  - `logo`: the logo's box. `top` is where the visible logo starts, and `gapBelow` is the space before the subtitle.
  - `tile`: the rounded square behind the topic's icon. It is `margin` in from the right edge and centred top to bottom.
  - `icon`: the icon, centred inside the tile. `offset` is the space between the tile's edge and the icon.
  - `textWidth`: how wide text can be, depending on whether there is an icon tile to leave room for.
  - `underlineToTaglineGap`: the space between the underline and the tagline.
  - `lowestTaglineY`: the tagline's last line must stay above this, in order to leave a margin at the bottom of the image.

-}
layout :
    { canvas : { width : Float, height : Float }
    , margin : Float
    , logo : { top : Float, width : Float, height : Float, gapBelow : Float }
    , tile : { left : Float, top : Float, size : Float, cornerRadius : Float }
    , icon : { offset : Float, size : Float }
    , textWidth : { withIcon : Float, withoutIcon : Float }
    , subtitleSize : Float
    , underlineToTaglineGap : Float
    , lowestTaglineY : Float
    }
layout =
    let
        canvas : { width : Float, height : Float }
        canvas =
            { width = 1200, height = 630 }

        margin : Float
        margin =
            80

        tileSize : Float
        tileSize =
            380

        iconSize : Float
        iconSize =
            240

        tileLeft : Float
        tileLeft =
            canvas.width - margin - tileSize

        tileGap : Float
        tileGap =
            36

        bottomMargin : Float
        bottomMargin =
            30
    in
    { canvas = canvas
    , margin = margin
    , logo = { top = 70, width = 100, height = 80, gapBelow = 110 }
    , tile = { left = tileLeft, top = (canvas.height - tileSize) / 2, size = tileSize, cornerRadius = 48 }
    , icon = { offset = (tileSize - iconSize) / 2, size = iconSize }
    , textWidth = { withIcon = tileLeft - tileGap - margin, withoutIcon = canvas.width - 2 * margin }
    , subtitleSize = 40
    , underlineToTaglineGap = 24
    , lowestTaglineY = canvas.height - bottomMargin
    }


{-| Turns the banner into SVG text, using the HTML renderer that elm-pages passes to `Api.routes`.
-}
toSvg : (Maybe { indent : Int, newLines : Bool } -> Html Never -> String) -> Banner -> String
toSvg renderHtml banner =
    renderHtml Nothing
        (Svg.svg
            [ Html.Attributes.attribute "xmlns" "http://www.w3.org/2000/svg"
            , width (String.fromFloat layout.canvas.width)
            , height (String.fromFloat layout.canvas.height)
            , viewBox ("0 0 " ++ String.fromFloat layout.canvas.width ++ " " ++ String.fromFloat layout.canvas.height)
            ]
            (shapes banner)
        )


{-| Everything in the banner, in drawing order, such that later items are drawn on top of earlier ones.
-}
shapes : Banner -> List (Svg Never)
shapes banner =
    let
        textWidth : Float
        textWidth =
            case banner.icon of
                Just _ ->
                    layout.textWidth.withIcon

                Nothing ->
                    layout.textWidth.withoutIcon

        ( titleSize, titleLines ) =
            fitTitle textWidth banner.title

        subtitleY : Float
        subtitleY =
            layout.logo.top + layout.logo.height + layout.logo.gapBelow

        firstTitleLineY : Float
        firstTitleLineY =
            subtitleY + titleSize

        lastTitleLineY : Float
        lastTitleLineY =
            firstTitleLineY + lineOffset titleStyle titleSize (List.length titleLines - 1)

        underlineTop : Float
        underlineTop =
            lastTitleLineY + titleSize * underlineStyle.offset

        underlineThickness : Float
        underlineThickness =
            titleSize * underlineStyle.thickness

        underlineStartGap : Float
        underlineStartGap =
            titleSize * underlineStyle.leftPad

        -- As wide as the longest title line.
        underlineWidth : Float
        underlineWidth =
            toFloat
                (List.map String.length titleLines |> List.maximum |> Maybe.withDefault 0)
                * titleSize
                * titleStyle.charWidth
                - underlineStartGap

        taglineTop : Float
        taglineTop =
            underlineTop + underlineThickness + layout.underlineToTaglineGap

        ( taglineSize, taglineLines ) =
            fitTagline textWidth (layout.lowestTaglineY - taglineTop) banner.tagline

        subtitle : Svg Never
        subtitle =
            textLines [] subtitleStyle layout.subtitleSize subtitleY [ banner.subtitle ]

        underline : Svg Never
        underline =
            Svg.rect
                (fill "url(#brand)"
                    :: box { left = layout.margin + underlineStartGap, top = underlineTop, width = underlineWidth, height = underlineThickness }
                )
                []

        title : Svg Never
        title =
            textLines
                [ stroke colours.background
                , strokeWidth (String.fromFloat (titleSize * underlineStyle.descenderGap))
                , strokeLinejoin "round"
                , Html.Attributes.attribute "paint-order" "stroke"
                ]
                titleStyle
                titleSize
                firstTitleLineY
                titleLines

        tagline : Svg Never
        tagline =
            textLines [] taglineStyle taglineSize (taglineTop + taglineSize) taglineLines

        iconTile : List (Svg Never)
        iconTile =
            case banner.icon of
                Just icon ->
                    [ Svg.rect
                        (rx (String.fromFloat layout.tile.cornerRadius)
                            :: fill colours.tile
                            :: box { left = layout.tile.left, top = layout.tile.top, width = layout.tile.size, height = layout.tile.size }
                        )
                        []
                    , image icon
                        { left = layout.tile.left + layout.icon.offset
                        , top = layout.tile.top + layout.icon.offset
                        , width = layout.icon.size
                        , height = layout.icon.size
                        }
                    ]

                Nothing ->
                    []
    in
    [ Svg.defs [] [ brandGradient ]
    , Svg.rect (fill colours.background :: box { left = 0, top = 0, width = layout.canvas.width, height = layout.canvas.height }) []
    , image banner.logo { left = layout.margin, top = layout.logo.top, width = layout.logo.width, height = layout.logo.height }
    , subtitle
    , underline
    , title
    , tagline
    ]
        ++ iconTile


brandGradient : Svg Never
brandGradient =
    Svg.linearGradient [ id "brand", x1 "0", x2 "1", y1 "0", y2 "0" ]
        (List.map (\( position, colour ) -> Svg.stop [ offset position, stopColor colour ] [])
            [ ( "0", colours.gradientStart ), ( "0.5", colours.accent ), ( "1", colours.gradientEnd ) ]
        )


type alias Box =
    { left : Float, top : Float, width : Float, height : Float }



-- | Turn a 'Box' into a list of SVG attributes in order to make the SVG fit within that box.


box : Box -> List (Svg.Attribute Never)
box rect =
    [ x (String.fromFloat rect.left)
    , y (String.fromFloat rect.top)
    , width (String.fromFloat rect.width)
    , height (String.fromFloat rect.height)
    ]


{-| One or more lines of text at the left margin, as one `<text>` with a `<tspan>` per line.
-}
textLines : List (Svg.Attribute Never) -> TextStyle -> Float -> Float -> List String -> Svg Never
textLines extraAttributes style size firstBaseline lines =
    Svg.text_
        ([ fontFamily style.font
         , fontWeight (String.fromInt style.weight)
         , fontSize (String.fromFloat size)
         , fill style.colour
         ]
            ++ extraAttributes
        )
        (List.indexedMap
            (\index line ->
                Svg.tspan
                    [ x (String.fromFloat layout.margin), y (String.fromFloat (firstBaseline + lineOffset style size index)) ]
                    [ Svg.text line ]
            )
            lines
        )


{-| How far below the first line's baseline line number `index` sits.
-}
lineOffset : TextStyle -> Float -> Int -> Float
lineOffset style size index =
    toFloat index * size * style.lineSpacing


{-| Puts an SVG file in the banner as an image.
-}
image : String -> Box -> Svg Never
image source rect =
    Svg.image
        (Html.Attributes.attribute "href" ("data:image/svg+xml;base64," ++ (Base64.fromString source |> Maybe.withDefault ""))
            :: box rect
        )
        []


{-| How many characters of this style fit on a line `maxWidth` wide at this font size.
-}
charsPerLine : TextStyle -> Float -> Float -> Int
charsPerLine style maxWidth size =
    floor (maxWidth / (size * style.charWidth))


{-| Tries each of `fontSizes sizes` in turn, biggest first, and gives back the first one where the text, broken into
lines, passes `fits`. If no sizes fit, the smallest one will be returned.
-}
fitText : TextStyle -> { a | largest : Float, smallest : Float } -> Float -> (Float -> List String -> Bool) -> String -> ( Float, List String )
fitText style sizes maxWidth fits content =
    let
        atSize : Float -> ( Float, List String )
        atSize size =
            ( size, wrap (charsPerLine style maxWidth size) content )
    in
    fontSizes sizes
        |> List.map atSize
        |> List.filter (\( size, lines ) -> fits size lines)
        |> List.head
        |> Maybe.withDefault (atSize sizes.smallest)


{-| Finds the biggest font size at which the title fits in `titleFit.maxLines` lines or fewer, without any single long
word being wider than `textWidth`. If nothing fits, the smallest size is used with as many lines as it takes.
-}
fitTitle : Float -> String -> ( Float, List String )
fitTitle textWidth title =
    let
        fits : Float -> List String -> Bool
        fits size lines =
            List.length lines <= titleFit.maxLines && List.all (\line -> String.length line <= charsPerLine titleStyle textWidth size) lines
    in
    fitText titleStyle titleFit textWidth fits title


{-| Finds the biggest font size at which the whole tagline fits in `heightAvailable` pixels of height, counted from
the first line's letters down to the last line's. Even the smallest size should stay readable when social sites shrink
the image.

If the text doesn't fit even at the smallest size, we cut it short at a word boundary and end it with "…".

-}
fitTagline : Float -> Float -> String -> ( Float, List String )
fitTagline textWidth heightAvailable tagline =
    let
        fits : Float -> List String -> Bool
        fits size lines =
            (size + lineOffset taglineStyle size (List.length lines - 1) <= heightAvailable)
                -- A word too long for any line can't be split, so shrink the text until it fits.
                && List.all (\line -> String.length line <= charsPerLine taglineStyle textWidth size) lines

        ( fittedSize, fittedLines ) =
            fitText taglineStyle taglineFit textWidth fits tagline
    in
    if fits fittedSize fittedLines then
        ( fittedSize, fittedLines )

    else
        let
            smallest : Float
            smallest =
                taglineFit.smallest

            maxChars : Int
            maxChars =
                charsPerLine taglineStyle textWidth smallest

            lines : List String
            lines =
                -- Keep one character free on every line, so the last visible line always has room for the "…".
                wrap (maxChars - 1) tagline

            -- How many lines fit, counting the last one which will be cut short.
            linesThatFit : Int
            linesThatFit =
                max 1 (floor ((heightAvailable - smallest) / (smallest * taglineStyle.lineSpacing)) + 1)

            lastLine : String
            lastLine =
                lines |> List.drop (linesThatFit - 1) |> List.head |> Maybe.withDefault ""
        in
        ( smallest, List.take (linesThatFit - 1) lines ++ [ lastLine ++ "…" ] )


{-| Breaks text into lines of at most `maxChars` characters, filling each line with as many words as fit.
-}
wrap : Int -> String -> List String
wrap maxChars content =
    let
        addWord : String -> List String -> List String
        addWord word lines =
            case lines of
                current :: earlier ->
                    if String.length current + 1 + String.length word <= maxChars then
                        (current ++ " " ++ word) :: earlier

                    else
                        word :: lines

                [] ->
                    [ word ]
    in
    String.words content |> List.foldl addWord [] |> List.reverse


{-| The `og:image` for the banner `Api.renderBanners` writes as `og/<file>.png`, with `alt` as its alt text.
-}
seoImage : String -> String -> Seo.Image
seoImage file alt =
    { url = UrlPath.fromString ("og/" ++ file ++ ".png") |> Pages.Url.fromPath
    , alt = alt
    , dimensions = Just { width = round layout.canvas.width, height = round layout.canvas.height }
    , mimeType = Just (MimeType.Image MimeType.Png)
    }
