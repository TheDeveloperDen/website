module Shiki exposing (Highlighted, Token, decoder, view)

{-| Code highlighted at build time by the `highlight` task in `custom-backend-task.ts`.

@docs Highlighted, Token, decoder, view

-}

import Bitwise
import Html exposing (Html)
import Html.Attributes as Attr
import Json.Decode as Decode exposing (Decoder)


{-| The lines of Tokens returned by `highlight`
-}
type alias Highlighted =
    List (List Token)


{-| A section of text with one colour and style.
-}
type alias Token =
    { content : String
    , color : Maybe String -- a CSS `var(--shiki-*)` reference
    , fontStyle : Int -- Shiki's `FontStyle` bit se
    }


{-| Decodes the result of the `highlight` task.
-}
decoder : Decoder Highlighted
decoder =
    Decode.list
        (Decode.list
            (Decode.map3 Token
                (Decode.field "content" Decode.string)
                (Decode.maybe (Decode.field "color" Decode.string))
                (Decode.oneOf [ Decode.field "fontStyle" Decode.int, Decode.succeed 0 ])
            )
        )


{-| A `<pre><code>` of `<span>`s, with one `<span>` per token.
-}
view : String -> Highlighted -> Html msg
view language lines =
    Html.pre []
        [ Html.code [ Attr.class ("language-" ++ language) ]
            (List.intersperse (Html.text "\n")
                (List.map (\line -> Html.span [] (List.map viewToken line)) lines)
            )
        ]


viewToken : Token -> Html msg
viewToken token =
    Html.span
        (List.filterMap identity
            [ Maybe.map (Attr.style "color") token.color
            , flag 1 "font-style" "italic" token
            , flag 2 "font-weight" "bold" token

            -- don't really care enough to support any of the other tags
            ]
        )
        [ Html.text token.content ]


flag : Int -> String -> String -> Token -> Maybe (Html.Attribute msg)
flag bit property value token =
    if Bitwise.and bit token.fontStyle /= 0 then
        Just (Attr.style property value)

    else
        Nothing
