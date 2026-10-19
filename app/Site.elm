module Site exposing (config)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import MimeType
import Pages.Url
import SiteConfig exposing (SiteConfig)
import UrlPath


config : SiteConfig
config =
    { canonicalUrl = "https://developerden.org"
    , head = head
    }


head : BackendTask FatalError (List Head.Tag)
head =
    [ Head.metaName "viewport" (Head.raw "width=device-width,initial-scale=1")
    , Head.sitemapLink "/sitemap.xml"
    , Head.icon [] (MimeType.OtherImage "svg+xml") (Pages.Url.fromPath (UrlPath.fromString "devden-logo.svg"))
    , Head.icon [] (MimeType.OtherImage "x-icon") (Pages.Url.fromPath (UrlPath.fromString "favicon.ico"))
    ]
        |> BackendTask.succeed
