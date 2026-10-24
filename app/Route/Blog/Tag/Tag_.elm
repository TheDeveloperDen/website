module Route.Blog.Tag.Tag_ exposing (ActionData, Data, Model, Msg, RouteParams, route)

import BackendTask exposing (BackendTask)
import Banner
import Blog
import BlogView
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html.Styled exposing (div)
import Html.Styled.Attributes exposing (css)
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
    { tag : String }


type alias Data =
    { name : String
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


pages : BackendTask FatalError (List RouteParams)
pages =
    Blog.fetchSummaries
        |> BackendTask.map
            (\summaries ->
                summaries
                    |> List.concatMap .tags
                    |> List.map Blog.tagSlug
                    |> List.filter (not << String.isEmpty)
                    |> List.Extra.unique
                    |> List.map (\tag -> { tag = tag })
            )


data : RouteParams -> BackendTask FatalError Data
data params =
    Blog.fetchSummaries
        |> BackendTask.map
            (\summaries ->
                let
                    posts : List Blog.Summary
                    posts =
                        List.filter (\summary -> List.any (\tag -> Blog.tagSlug tag == params.tag) summary.tags) summaries
                in
                { -- the spelling of a tag is dictated of the first post using it
                  -- bit arbitrary, but sadly our tag mapping isn't injective so can't do much about it
                  name =
                    posts
                        |> List.concatMap .tags
                        |> List.Extra.find (\tag -> Blog.tagSlug tag == params.tag)
                        |> Maybe.withDefault params.tag
                , posts = posts
                }
            )


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    Seo.summaryLarge
        { canonicalUrlOverride = Nothing
        , siteName = "Developer Den"
        , image = Banner.seoImage "default" "Developer Den"
        , description = "Posts tagged " ++ app.data.name ++ " on the Developer Den blog."
        , locale = Nothing
        , title = "Posts tagged " ++ app.data.name ++ " | Developer Den"
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    View.fromStyled ("Tagged " ++ app.data.name)
        [ div [ css [ Tw.pt_12, Tw.pb_24, Tw.max_w_5xl, Tw.mx_auto, Tw.w_full, Theming.gutter ] ]
            [ div [ css [ Tw.mb_12 ] ] [ Theming.pageTitle ("tagged " ++ app.data.name) ]
            , BlogView.viewPostList app.data.posts
            ]
        ]
        |> View.map PagesMsg.fromMsg
