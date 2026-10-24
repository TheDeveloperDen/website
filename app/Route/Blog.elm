module Route.Blog exposing (ActionData, Data, Model, Msg, RouteParams, route)

import BackendTask exposing (BackendTask)
import Banner
import Blog
import BlogView
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html.Styled exposing (a, br, div, p, text)
import Html.Styled.Attributes exposing (css, href)
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
    {}


type alias Data =
    { posts : List Blog.Summary }


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    Blog.fetchSummaries
        |> BackendTask.map
            (\summaries ->
                { posts = summaries }
            )


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summaryLarge
        { canonicalUrlOverride = Nothing
        , siteName = "Developer Den"
        , image = Banner.seoImage "default" "Developer Den"
        , description = "Posts from the Developer Den community."
        , locale = Nothing
        , title = "Blog | Developer Den"
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    View.fromStyled "Blog"
        [ div [ css [ Tw.pt_12, Tw.pb_24, Tw.max_w_5xl, Tw.mx_auto, Tw.w_full, Theming.gutter ] ]
            [ div [ css [ Tw.mb_6 ] ] [ Theming.pageTitle "blog" ]
            , p [ css [ Theming.bodyFont, Tw.text_lg, Tw.m_0, Tw.mb_12 ] ]
                [ text "All the posts here are hand-written by our members!"
                , br [] []
                , text "Interested in posting yourself? Check out the "
                , a [ href "https://github.com/TheDeveloperDen/blog/tree/master" ] [ text "GitHub!" ]
                ]
            , BlogView.viewPostList app.data.posts
            ]
        ]
        |> View.map PagesMsg.fromMsg
