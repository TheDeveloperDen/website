module Route.Github.Link exposing (ActionData, Data, Model, Msg, RouteParams, route)

{-| Landing page the Discord bot redirects to after a GitHub authorisation (`/github/link?result=...&guild=...&channel=...`).
-}

import BackendTask
import Dict
import Head
import Html.Styled exposing (Html, a, div, p, text)
import Html.Styled.Attributes exposing (css, href)
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Tailwind.Breakpoints as Breakpoints
import Tailwind.Utilities as Tw
import Theming
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


type LinkResult
    = Linked
    | Expired
    | Invalid
    | Denied
    | AlreadyLinked
    | Failed


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = BackendTask.succeed ()
        }
        |> RouteBuilder.buildNoState { view = view }


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    [ Head.metaName "robots" (Head.raw "noindex")
    , Head.metaName "description" (Head.raw "The result of linking your GitHub account to Discord.")
    ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    let
        query : Dict.Dict String (List String)
        query =
            app.url |> Maybe.map .query |> Maybe.withDefault Dict.empty

        param : String -> Maybe String
        param name =
            Dict.get name query |> Maybe.andThen List.head

        outcome : LinkResult
        outcome =
            parseResult (param "result")

        guild =
            param "guild"

        channel =
            param "channel"
    in
    View.fromStyled "GitHub link"
        [ div [ css [ Tw.flex, Tw.flex_col, Tw.items_center, Tw.justify_center, Tw.w_full, Tw.flex_grow, Theming.gutter, Tw.py_16, Tw.text_center ] ]
            [ Theming.pageTitle (heading outcome)
            , p [ css [ Theming.bodyFont, Tw.text_xl, Tw.max_w_2xl, Tw.leading_relaxed, Tw.mt_10, Tw.mb_0 ] ] [ text (explanation outcome) ]
            , hint outcome
            , div [ css [ Tw.flex, Tw.flex_col, Tw.w_full, Tw.max_w_xs, Tw.gap_4, Tw.mt_12, Breakpoints.sm [ Tw.flex_row, Tw.w_auto, Tw.max_w_none ] ] ]
                [ button (discordUrl guild channel) "return to discord"
                , button "/" "go to homepage"
                ]
            ]
        ]
        |> View.map PagesMsg.fromMsg


parseResult : Maybe String -> LinkResult
parseResult result =
    case result of
        Just "linked" ->
            Linked

        Just "expired" ->
            Expired

        Just "invalid" ->
            Invalid

        Just "denied" ->
            Denied

        Just "already-linked" ->
            AlreadyLinked

        _ ->
            Failed


heading : LinkResult -> String
heading outcome =
    case outcome of
        Linked ->
            "Successfully linked!"

        Expired ->
            "Link expired"

        Invalid ->
            "Invalid request"

        Denied ->
            "Authorisation cancelled"

        AlreadyLinked ->
            "Already linked"

        Failed ->
            "Something went wrong"


explanation : LinkResult -> String
explanation outcome =
    case outcome of
        Linked ->
            "Your GitHub account is now connected to your Discord profile!"

        Expired ->
            "This authorisation link has expired or has already been used."

        Invalid ->
            "The request was malformed, so we couldn't link your account."

        Denied ->
            "GitHub didn't give us an authorisation code, usually because the request was cancelled."

        AlreadyLinked ->
            "That GitHub account is already linked to a different Discord account."

        Failed ->
            "An error occurred on our side while linking your account."


hint : LinkResult -> Html msg
hint outcome =
    case outcome of
        Linked ->
            text ""

        AlreadyLinked ->
            hintText "Each GitHub account can only be linked to one Discord account. If this is unexpected, please contact a moderator."

        _ ->
            hintText "Run /github link again in Discord to get a new link."


hintText : String -> Html msg
hintText message =
    p [ css [ Theming.bodyFont, Tw.text_lg, Tw.max_w_2xl, Tw.leading_relaxed, Tw.mt_4, Tw.mb_0 ] ] [ text message ]



-- | A redirect to the exact discord channel, or just the Discord app


discordUrl : Maybe String -> Maybe String -> String
discordUrl guild channel =
    case ( Maybe.andThen validGuild guild, Maybe.andThen validChannel channel ) of
        ( Just g, Just c ) ->
            "https://discord.com/channels/" ++ g ++ "/" ++ c

        _ ->
            "https://discord.com/app"


validGuild : String -> Maybe String
validGuild id =
    if id == "@me" || isDigits id then
        Just id

    else
        Nothing


validChannel : String -> Maybe String
validChannel id =
    if isDigits id then
        Just id

    else
        Nothing


isDigits : String -> Bool
isDigits s =
    s /= "" && String.all Char.isDigit s


button : String -> String -> Html msg
button url label =
    a [ href url, css [ Theming.gradientButton, Tw.w_full, Breakpoints.sm [ Tw.w_auto ] ] ] [ text label ]
