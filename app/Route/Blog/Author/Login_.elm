module Route.Blog.Author.Login_ exposing (ActionData, Data, Model, Msg, RouteParams, route)

import BackendTask exposing (BackendTask)
import Banner
import Blog
import BlogView
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html.Styled as Html exposing (Html, a, div, p, text)
import Html.Styled.Attributes as Attr exposing (css)
import List.Extra
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Tailwind.Utilities as Tw
import Theming
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    { login : String }


type alias Data =
    { login : String
    , name : String
    , bio : Maybe String
    , posts : List Blog.Summary
    }


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.preRender
        { head = head
        , pages = pages
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


{-| One page per author, keyed by their username in lowercase
-}
pages : BackendTask FatalError (List RouteParams)
pages =
    Blog.fetchSummaries
        |> BackendTask.map
            (\summaries ->
                summaries
                    |> List.concatMap .authors
                    |> List.map (\author -> String.toLower author.login)
                    |> List.Extra.unique
                    |> List.map (\login -> { login = login })
            )


data : RouteParams -> BackendTask FatalError Data
data params =
    Blog.fetchSummaries
        |> BackendTask.andThen
            (\summaries ->
                let
                    mine : List Blog.Summary
                    mine =
                        List.filter (\summary -> List.any (\author -> Blog.sameLogin author.login params.login) summary.authors) summaries
                in
                case mine |> List.concatMap .authors |> List.filter (\author -> Blog.sameLogin author.login params.login) |> List.head of
                    Just author ->
                        BackendTask.succeed
                            { login = author.login
                            , name = author.name
                            , bio = author.bio
                            , posts = mine
                            }

                    Nothing ->
                        BackendTask.fail (FatalError.fromString ("Unknown blog author: " ++ params.login))
            )


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    Seo.summaryLarge
        { canonicalUrlOverride = Nothing
        , siteName = "Developer Den"
        , image = Banner.seoImage "default" "Developer Den"
        , description = "Posts by " ++ app.data.name ++ " on the Developer Den blog."
        , locale = Nothing
        , title = app.data.name ++ " | Developer Den blog"
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    View.fromStyled app.data.name
        [ div [ css [ Tw.pt_12, Tw.pb_24, Tw.max_w_5xl, Tw.mx_auto, Tw.w_full, Theming.gutter ] ]
            [ div [ css [ Tw.mb_6, Tw.flex, Tw.items_center, Tw.gap_5 ] ] [ BlogView.avatar 72 app.data.login, Theming.pageTitle app.data.name ]
            , a [ Attr.href ("https://github.com/" ++ app.data.login), Attr.target "_blank", css [ Theming.quietLink, Theming.bodyFont ] ] [ text ("@" ++ app.data.login ++ " on GitHub") ]
            , viewBio app.data.bio
            , Html.h2 [ css [ Theming.headingFont, Tw.text_2xl, Tw.font_semibold, Tw.mt_12, Tw.mb_6 ] ] [ text "posts" ]
            , BlogView.viewPostList app.data.posts
            ]
        ]
        |> View.map PagesMsg.fromMsg


{-| Render a bio as markdown
-}
viewBio : Maybe String -> Html msg
viewBio maybeBio =
    case maybeBio |> Maybe.map (Blog.renderBody "") of
        Just (Ok rendered) ->
            div [ css [ Theming.prose, Tw.mt_6 ] ] (List.map Html.fromUnstyled rendered)

        _ ->
            p [] []
