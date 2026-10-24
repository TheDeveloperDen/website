module Route.Blog.Slug_ exposing (ActionData, Data, Model, Msg, RouteParams, route)

import BackendTask exposing (BackendTask)
import Banner
import Blog
import BlogView
import DateOrDateTime
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html.Styled as Html exposing (Html, div, p, text)
import Html.Styled.Attributes exposing (css)
import Iso8601
import Json.Encode
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Tailwind.Breakpoints as Breakpoints
import Tailwind.Utilities as Tw
import Theming
import Time
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    { slug : String }


type alias Data =
    { title : String
    , description : String
    , authors : List Blog.Author
    , tags : List String
    , published : Maybe Time.Posix
    , body : String
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
    Blog.postSlugs |> BackendTask.map (List.map (\slug -> { slug = slug }))


data : RouteParams -> BackendTask FatalError Data
data params =
    Blog.fetchPost params.slug
        |> BackendTask.map
            (\post ->
                { title = post.title
                , description = post.description
                , authors = post.authors
                , tags = post.tags
                , published = post.published
                , body = post.body
                }
            )


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    Head.structuredData (blogPosting { title = app.data.title, description = app.data.description, authors = app.data.authors, published = app.data.published })
        :: (Seo.summaryLarge
                { canonicalUrlOverride = Nothing
                , siteName = "Developer Den"
                , image = Banner.seoImage (Banner.postFile app.routeParams.slug) app.data.title
                , description = app.data.description
                , locale = Nothing
                , title = app.data.title ++ " | Developer Den"
                }
                |> Seo.article
                    { tags = app.data.tags
                    , section = Nothing
                    , publishedTime = Maybe.map DateOrDateTime.DateTime app.data.published
                    , modifiedTime = Nothing
                    , expirationTime = Nothing
                    }
           )


{-| schema.org `BlogPosting`, so search engines can show the author and publish date.
-}
blogPosting : { title : String, description : String, authors : List Blog.Author, published : Maybe Time.Posix } -> Json.Encode.Value
blogPosting post =
    Json.Encode.object
        ([ ( "@context", Json.Encode.string "https://schema.org" )
         , ( "@type", Json.Encode.string "BlogPosting" )
         , ( "headline", Json.Encode.string post.title )
         , ( "description", Json.Encode.string post.description )
         , ( "author", Json.Encode.list (\author -> Json.Encode.object [ ( "@type", Json.Encode.string "Person" ), ( "name", Json.Encode.string author.name ) ]) post.authors )
         ]
            ++ (post.published |> Maybe.map (\date -> [ ( "datePublished", Json.Encode.string (Iso8601.fromTime date) ) ]) |> Maybe.withDefault [])
        )


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    View.fromStyled app.data.title
        [ div [ css [ Tw.pt_16, Tw.pb_32, Tw.max_w_4xl, Tw.mx_auto, Tw.w_full, Tw.px_6, Breakpoints.md [ Tw.px_12 ] ] ]
            [ Theming.pageTitle app.data.title
            , div [ css [ Tw.mt_4, Tw.mb_4 ] ] [ BlogView.metaLine app.data.authors app.data.published ]
            , div [ css [ Tw.flex, Tw.flex_wrap, Tw.gap_2, Tw.mb_12 ] ] (List.map BlogView.tagLink app.data.tags)
            , viewMarkdown app.routeParams.slug app.data.body
            , div [ css [ Tw.mt_16, Tw.flex, Tw.flex_col, Tw.gap_6 ] ] (List.filterMap viewAuthorBox app.data.authors)
            ]
        ]
        |> View.map PagesMsg.fromMsg


{-| A short "about the author" box, for authors who wrote a bio.
-}
viewAuthorBox : Blog.Author -> Maybe (Html msg)
viewAuthorBox author =
    author.bio
        |> Maybe.map
            (\bio ->
                Theming.cardShell [ Tw.p_6, Tw.flex, Tw.flex_col, Tw.gap_2 ]
                    [ div [ css [ Tw.flex, Tw.items_center, Tw.gap_3 ] ] [ BlogView.avatar 40 author.login, p [ css [ Theming.bodyFont, Tw.m_0, Tw.font_semibold ] ] [ text author.name ] ]
                    , viewMarkdown "" bio
                    ]
            )


viewMarkdown : String -> String -> Html msg
viewMarkdown slug markdown =
    case Blog.renderBody slug markdown of
        Ok rendered ->
            Html.div [ css [ Theming.prose ] ] (List.map Html.fromUnstyled rendered)

        Err message ->
            p [] [ text message ]
