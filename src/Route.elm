module Route exposing (Route(..), fromUrl, href, maybeFromUrl, routeToString)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), (<?>), Parser, oneOf)
import Url.Parser.Query as Query


type Route
    = Home
    | Rules
    | ServicesRules
    | Discord
    | LearningResources (Maybe String)


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Rules (Parser.s "rules")
        , Parser.map ServicesRules (Parser.s "services-rules")
        , Parser.map Discord (Parser.s "discord")
        , Parser.map (LearningResources Nothing) (Parser.s "learning-resources")
        , Parser.map (\s -> LearningResources (Just s)) (Parser.s "learning-resources" </> Parser.string)
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

        LearningResources res ->
            [ "learning-resources", Maybe.withDefault "" res ]
