module Api exposing (routes)

import ApiRoute exposing (ApiRoute)
import BackendTask exposing (BackendTask)
import BackendTask.Custom
import BackendTask.File
import BackendTask.Http
import Banner
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


{-| Renders `dist/og/default.png` and one `dist/og/<topic>.png` per topic.
Returns the plain/simple names of the banners written (`default` and each topic tag).
-}
renderBanners : (Maybe { indent : Int, newLines : Bool } -> Html Never -> String) -> BackendTask FatalError (List String)
renderBanners renderHtml =
    Db.fetchDatabase
        |> BackendTask.andThen
            (\db ->
                (Nothing :: List.map Just db.metadata)
                    |> List.map (renderBanner renderHtml)
                    |> BackendTask.combine
            )


bannerDir : String
bannerDir =
    "dist/og"


bannerManifest : List String -> String
bannerManifest files =
    Json.Encode.encode 2 (Json.Encode.list Json.Encode.string files)


renderBanner : (Maybe { indent : Int, newLines : Bool } -> Html Never -> String) -> Maybe LearningResources.CompiledMeta -> BackendTask FatalError String
renderBanner renderHtml maybeMeta =
    let
        file : String
        file =
            maybeMeta |> Maybe.map (.id >> LearningResources.entityTagToString) |> Maybe.withDefault "default"
    in
    BackendTask.map2
        (\logo icon ->
            case maybeMeta of
                Just meta ->
                    { subtitle = "learn", title = String.toLower meta.name, tagline = firstSentence meta.description, logo = logo, icon = icon }

                Nothing ->
                    { subtitle = "welcome to", title = "developer den", tagline = "a community of programmers learning together", logo = logo, icon = Nothing }
        )
        (BackendTask.File.rawFile "public/devden-logo.svg" |> BackendTask.allowFatal)
        (maybeMeta |> Maybe.andThen .icon |> fetchIcon)
        |> BackendTask.andThen
            (\banner ->
                BackendTask.Custom.run "writePng"
                    (Json.Encode.object [ ( "path", Json.Encode.string (bannerDir ++ "/" ++ file ++ ".png") ), ( "svg", Json.Encode.string (Banner.toSvg renderHtml banner) ) ])
                    (Json.Decode.succeed file)
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
