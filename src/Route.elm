module Route exposing (Route(..), fromUrl, href)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf)


type Route
    = Home
    | Rules


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Rules (Parser.s "rules")
        ]


href : Route -> Attribute msg
href target =
    Attr.href (routeToString target)


fromUrl : Url -> Route
fromUrl url =
    case ( Parser.parse parser url ) of
        (Just route) ->
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
