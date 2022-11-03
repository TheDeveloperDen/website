module Route exposing (Route(..), fromUrl, href, maybeFromUrl, routeToString)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf)


type Route
    = Home
    | Rules
    | ServicesRules
    | Discord


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Rules (Parser.s "rules")
        , Parser.map ServicesRules (Parser.s "services-rules")
        , Parser.map Discord (Parser.s "discord")
        ]


href : Route -> Attribute msg
href target =
    Attr.href (routeToString target)


maybeFromUrl : Url -> Maybe Route
maybeFromUrl url =
    Parser.parse parser url


fromUrl : Url -> Route
fromUrl url =
    case Parser.parse parser url of
        Just route ->
            route

        Nothing ->
            Home


routeToString : Route -> String
routeToString route =
    "/" ++ String.join "/" (routeToPieces route)


routeToPieces : Route -> List String
routeToPieces route =
    case route of
        Home ->
            []

        Rules ->
            [ "rules" ]

        ServicesRules ->
            [ "services-rules" ]

        Discord ->
            [ "discord" ]
