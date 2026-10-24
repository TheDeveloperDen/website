module Blog exposing (Author, HighlightCodeBlock, Post, Summary, fetchPost, fetchSummaries, formatDate, postSlugs, renderBody, sameLogin, tagSlug)

{-| Posts from the `TheDeveloperDen/blog` repo.
The files this code reads should be cloned at `content/blog` and `content/blog-dates.json` by `prepare-blog.ts`.

@docs Author, Highlight, Post, Summary, fetchPost, fetchSummaries, formatDate, postSlugs, renderBody, sameLogin, tagSlug

-}

import BackendTask exposing (BackendTask)
import BackendTask.Custom
import BackendTask.File as File
import BackendTask.Glob as Glob
import Date
import Dict exposing (Dict)
import FatalError exposing (FatalError)
import Html as UnstyledHtml
import Html.Attributes as UnstyledAttr
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Markdown.Block as Block
import Markdown.Parser
import Markdown.Renderer
import Shiki
import Time


{-| A post's author. `name` falls back to the GitHub login when they have no profile.
-}
type alias Author =
    { login : String
    , name : String
    , bio : Maybe String
    }


{-| A post.
`description` is the frontmatter's `summary`, or the start of the post.
-}
type alias Post =
    { title : String
    , description : String
    , authors : List Author
    , tags : List String
    , published : Maybe Time.Posix
    , body : String
    , highlighted : List HighlightCodeBlock
    }


type alias HighlightCodeBlock =
    { language : String
    , code : String
    , tokens : Shiki.Highlighted
    }


type alias Frontmatter =
    { title : String
    , authors : List String
    , tags : List String
    , summary : Maybe String
    }


postsDir : String
postsDir =
    "content/blog/posts/"


authorsDir : String
authorsDir =
    "content/blog/authors/"


{-| The folder name of every post, which is also its URL (`/blog/<slug>`).
-}
postSlugs : BackendTask FatalError (List String)
postSlugs =
    Glob.succeed identity
        |> Glob.match (Glob.literal postsDir)
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal "/index.md")
        |> Glob.toBackendTask
        -- posts starting with `_` are unpublished templates
        |> BackendTask.map (List.filter (not << String.startsWith "_"))


newestFirst : (a -> Maybe Time.Posix) -> List a -> List a
newestFirst published items =
    List.sortBy
        (\item ->
            published item
                |> Maybe.map Time.posixToMillis
                |> Maybe.withDefault 0
        )
        items
        |> List.reverse


{-| A post without its body, for listings.
-}
type alias Summary =
    { slug : String
    , title : String
    , description : String
    , authors : List Author
    , tags : List String
    , published : Maybe Time.Posix
    }


{-| Every post as a `Summary`, newest first.
-}
fetchSummaries : BackendTask FatalError (List Summary)
fetchSummaries =
    BackendTask.map3
        (\slugs names dates ->
            List.map (\slug -> readPost names dates slug |> BackendTask.map (summary slug)) slugs
        )
        postSlugs
        authorNames
        publishedDates
        |> BackendTask.andThen BackendTask.combine
        |> BackendTask.map (newestFirst .published)


summary : String -> Post -> Summary
summary slug post =
    -- grr i wish elm had proper record updates / structural typing
    { slug = slug
    , title = post.title
    , description = post.description
    , authors = post.authors
    , tags = post.tags
    , published = post.published
    }


{-| A date as `YYYY-MM-DD` (UTC)
-}
formatDate : Time.Posix -> String
formatDate posix =
    Date.toIsoString (Date.fromPosix Time.utc posix)


{-| Normalise a tag's slug into an URL-friendly form, lowercased, anything non alphanumeric stripped, and spaces replaced with `-`
-}
tagSlug : String -> String
tagSlug tag =
    tag
        |> String.toLower
        |> String.map
            (\char ->
                if Char.isAlphaNum char then
                    char

                else
                    ' '
            )
        |> String.words
        |> String.join "-"


{-| Whether two GitHub logins are the same account.
-}
sameLogin : String -> String -> Bool
sameLogin a b =
    String.toLower a == String.toLower b


{-| Read and validate the post in `posts/<slug>/index.md`.
-}
fetchPost : String -> BackendTask FatalError Post
fetchPost slug =
    BackendTask.map2 Tuple.pair authorNames publishedDates
        |> BackendTask.andThen (\( names, dates ) -> readPost names dates slug)
        |> BackendTask.andThen (\post -> highlightBlocks post.body |> BackendTask.map (\highlighted -> { post | highlighted = highlighted }))


{-| Highlights every fenced code block by running the `highlight` task in `custom-backend-task.ts`.

-}
highlightBlocks : String -> BackendTask FatalError (List HighlightCodeBlock)
highlightBlocks markdown =
    Markdown.Parser.parse markdown
        |> Result.withDefault []
        |> Block.foldl
            (\block blocks ->
                case block of
                    Block.CodeBlock { body, language } ->
                        ( Maybe.withDefault "text" language, body ) :: blocks

                    _ ->
                        blocks
            )
            []
        |> List.map
            (\( language, code ) ->
                BackendTask.Custom.run "highlight"
                    (Encode.object [ ( "lang", Encode.string language ), ( "code", Encode.string code ) ])
                    Shiki.decoder
                    |> BackendTask.allowFatal
                    |> BackendTask.map (HighlightCodeBlock language code)
            )
        |> BackendTask.combine


readPost : List String -> Dict String Int -> String -> BackendTask FatalError Post
readPost names dates slug =
    File.bodyWithFrontmatter
        (\body -> Decode.map (\frontmatter -> ( frontmatter, body )) frontmatterDecoder)
        (postsDir ++ slug ++ "/index.md")
        |> BackendTask.allowFatal
        |> BackendTask.andThen
            (\( frontmatter, body ) ->
                BackendTask.map
                    (\authors ->
                        { title = frontmatter.title
                        , description = Maybe.withDefault (firstParagraph body) frontmatter.summary
                        , authors = authors
                        , tags = frontmatter.tags
                        , published = Dict.get slug dates |> Maybe.map Time.millisToPosix
                        , body = body
                        , highlighted = []
                        }
                    )
                    (BackendTask.combine (List.map (fetchAuthor names) frontmatter.authors))
            )


{-| Read the `blog-dates.json` written by `prepare-blog.ts`, to get the publication dates of all the posts.
-}
publishedDates : BackendTask FatalError (Dict String Int)
publishedDates =
    File.jsonFile (Decode.dict Decode.int) "content/blog-dates.json"
        |> BackendTask.allowFatal


frontmatterDecoder : Decoder Frontmatter
frontmatterDecoder =
    Decode.map4 Frontmatter
        (Decode.field "title" Decode.string)
        (Decode.field "authors" (Decode.list Decode.string))
        (Decode.oneOf [ Decode.field "tags" (Decode.list Decode.string), Decode.succeed [] ])
        (Decode.maybe (Decode.field "summary" Decode.string))


authorNames : BackendTask FatalError (List String)
authorNames =
    Glob.succeed identity
        |> Glob.match (Glob.literal authorsDir)
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toBackendTask


fetchAuthor : List String -> String -> BackendTask FatalError Author
fetchAuthor names login =
    -- profiles are case insensitive
    case List.filter (\name -> String.toLower name == String.toLower login) names of
        name :: _ ->
            File.bodyWithFrontmatter
                (\bio ->
                    Decode.map
                        (\displayName ->
                            { login = login, name = Maybe.withDefault login displayName, bio = nonEmpty bio }
                        )
                        (Decode.maybe (Decode.field "name" Decode.string))
                )
                (authorsDir ++ name ++ ".md")
                |> BackendTask.allowFatal

        [] ->
            BackendTask.succeed { login = login, name = login, bio = Nothing }


nonEmpty : String -> Maybe String
nonEmpty text =
    if String.isEmpty (String.trim text) then
        Nothing

    else
        Just (String.trim text)


{-| Plain text of the first paragraph, trimmed to 160 characters max.
-}
firstParagraph : String -> String
firstParagraph body =
    let
        text : String
        text =
            Markdown.Parser.parse body
                |> Result.withDefault []
                |> List.filterMap
                    (\block ->
                        case block of
                            Block.Paragraph inlines ->
                                Just (Block.extractInlineText inlines)

                            _ ->
                                Nothing
                    )
                |> List.head
                |> Maybe.withDefault ""
    in
    if String.length text > 160 then
        String.left 157 text ++ "..."

    else
        text


{-| Render a post's Markdown.
-}
renderBody : String -> List HighlightCodeBlock -> String -> Result String (List (UnstyledHtml.Html msg))
renderBody slug highlighted markdown =
    Markdown.Parser.parse markdown
        |> Result.mapError (\_ -> "Could not parse this post.")
        |> Result.andThen (Markdown.Renderer.render (renderer slug highlighted))


renderer : String -> List HighlightCodeBlock -> Markdown.Renderer.Renderer (UnstyledHtml.Html msg)
renderer slug highlighted =
    let
        defaults : Markdown.Renderer.Renderer (UnstyledHtml.Html msg)
        defaults =
            Markdown.Renderer.defaultHtmlRenderer

        -- Rewrite a relative image link `/blog/<slug>/<file>` where it actually is published
        imageSource : String -> String
        imageSource source =
            if String.contains "://" source || String.startsWith "/" source then
                source

            else
                "/blog/" ++ slug ++ "/" ++ source
    in
    { defaults
        | codeBlock =
            \block ->
                highlighted
                    |> List.filter (\highlight -> highlight.code == block.body && highlight.language == Maybe.withDefault "text" block.language)
                    |> List.head
                    |> Maybe.map (\highlight -> Shiki.view highlight.language highlight.tokens)
                    |> Maybe.withDefault (defaults.codeBlock block)
        , image =
            \image ->
                UnstyledHtml.img
                    (UnstyledAttr.src (imageSource image.src)
                        :: UnstyledAttr.alt image.alt
                        :: (image.title |> Maybe.map (\title -> [ UnstyledAttr.title title ]) |> Maybe.withDefault [])
                    )
                    []
    }
