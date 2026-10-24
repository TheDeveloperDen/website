module Api exposing (routes)

import ApiRoute exposing (ApiRoute)
import BackendTask exposing (BackendTask)
import BackendTask.Custom
import BackendTask.File
import BackendTask.Http
import Banner
import Blog
import FatalError exposing (FatalError)
import Html exposing (Html)
import Json.Decode
import Json.Encode
import LearningResources as Db
import LearningResources.Types as LearningResources
import Route exposing (Route)
import UrlPath


routes :
    BackendTask FatalError (List Route)
    -> (Maybe { indent : Int, newLines : Bool } -> Html Never -> String)
    -> List (ApiRoute ApiRoute.Response)
routes getStaticRoutes renderHtml =
    [ ApiRoute.succeed (BackendTask.map sitemap getStaticRoutes)
        |> ApiRoute.literal "sitemap.xml"
        |> ApiRoute.single
    , ApiRoute.succeed (BackendTask.map bannerManifest (renderBanners renderHtml))
        |> ApiRoute.literal "og/manifest.json"
        |> ApiRoute.single
    ]


{-| Renders `dist/og/default.png`, one `dist/og/<topic>.png` per topic, and one per blog post (see `Banner.postFile`).
Returns the plain/simple names of the banners written.
-}
renderBanners : (Maybe { indent : Int, newLines : Bool } -> Html Never -> String) -> BackendTask FatalError (List String)
renderBanners renderHtml =
    BackendTask.map2
        (\db posts -> defaultSpec :: List.map topicSpec db.metadata ++ List.map postSpec posts)
        Db.fetchDatabase
        Blog.fetchSummaries
        |> BackendTask.andThen (List.map (renderBanner renderHtml) >> BackendTask.combine)


type alias BannerSpec =
    { file : String
    , subtitle : String
    , title : String
    , tagline : String
    , icon : Maybe LearningResources.EntityIcon
    }


defaultSpec : BannerSpec
defaultSpec =
    { file = "default", subtitle = "welcome to", title = "developer den", tagline = "a community of programmers learning together", icon = Nothing }


topicSpec : LearningResources.CompiledMeta -> BannerSpec
topicSpec meta =
    { file = LearningResources.entityTagToString meta.id
    , subtitle = "learn"
    , title = String.toLower meta.name
    , tagline = firstSentence meta.description
    , icon = meta.icon
    }


postSpec : Blog.Summary -> BannerSpec
postSpec post =
    { file = Banner.postFile post.slug, subtitle = "blog", title = String.toLower post.title, tagline = post.description, icon = Nothing }


bannerDir : String
bannerDir =
    "dist/og"


bannerManifest : List String -> String
bannerManifest files =
    Json.Encode.encode 2 (Json.Encode.list Json.Encode.string files)


renderBanner : (Maybe { indent : Int, newLines : Bool } -> Html Never -> String) -> BannerSpec -> BackendTask FatalError String
renderBanner renderHtml spec =
    BackendTask.map2
        (\logo icon -> { subtitle = spec.subtitle, title = spec.title, tagline = spec.tagline, logo = logo, icon = icon })
        (BackendTask.File.rawFile "public/devden-logo.svg" |> BackendTask.allowFatal)
        (fetchIcon spec.icon)
        |> BackendTask.andThen
            (\banner ->
                BackendTask.Custom.run "writePng"
                    (Json.Encode.object [ ( "path", Json.Encode.string (bannerDir ++ "/" ++ spec.file ++ ".png") ), ( "svg", Json.Encode.string (Banner.toSvg renderHtml banner) ) ])
                    (Json.Decode.succeed spec.file)
                    |> BackendTask.allowFatal
            )


{-| The description's first sentence, so long descriptions stay readable on the banner.
-}
firstSentence : String -> String
firstSentence description =
    String.indexes ". " description
        |> List.filter (\index -> String.slice (index + 2) (index + 3) description |> String.any Char.isUpper)
        |> List.head
        |> Maybe.map (\index -> String.left (index + 1) description)
        |> Maybe.withDefault description


{-| Banners sit on a dark background, so prefer the icon's dark variant.
-}
fetchIcon : Maybe LearningResources.EntityIcon -> BackendTask FatalError (Maybe String)
fetchIcon maybeIcon =
    case maybeIcon of
        Just icon ->
            BackendTask.Http.get (Db.iconUrl (Maybe.withDefault icon.default icon.dark)) BackendTask.Http.expectString
                |> BackendTask.allowFatal
                |> BackendTask.map Just

        Nothing ->
            BackendTask.succeed Nothing


sitemap : List Route -> String
sitemap staticRoutes =
    let
        urlEntry : Route -> String
        urlEntry route =
            "  <url><loc>https://developerden.org" ++ UrlPath.toAbsolute (Route.toPath route) ++ "</loc></url>"
    in
    String.join "\n"
        ([ "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
         , "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">"
         ]
            ++ List.map urlEntry (List.filter (\route -> route /= Route.Github__Link) staticRoutes)
            ++ [ "</urlset>" ]
        )
