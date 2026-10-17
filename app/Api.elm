module Api exposing (routes)

import ApiRoute exposing (ApiRoute)
import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Html exposing (Html)
import Route exposing (Route)
import UrlPath


routes :
    BackendTask FatalError (List Route)
    -> (Maybe { indent : Int, newLines : Bool } -> Html Never -> String)
    -> List (ApiRoute ApiRoute.Response)
routes getStaticRoutes _ =
    [ ApiRoute.succeed (BackendTask.map sitemap getStaticRoutes)
        |> ApiRoute.literal "sitemap.xml"
        |> ApiRoute.single
    ]


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
            ++ List.map urlEntry staticRoutes
            ++ [ "</urlset>" ]
        )
