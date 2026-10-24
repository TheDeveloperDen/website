module BlogView exposing
    ( avatar, tagLink, viewPostList
    , metaLine
    )

{-| Pieces shared by the blog index, author pages, tag pages and posts.

@docs avatar, byline, tagLink, viewPostList

-}

import Blog
import Css
import Css.Global as Global
import Html.Styled as Html exposing (Html, a, div, p, span, text)
import Html.Styled.Attributes as Attr exposing (css)
import Route
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw
import Theming
import Time
import UrlPath


{-| An author's GitHub avatar as a `size` px square.
-}
avatar : Int -> String -> Html msg
avatar size login =
    Html.img
        [ Attr.src ("https://github.com/" ++ login ++ ".png?size=" ++ String.fromInt (size * 2))
        , Attr.alt ""
        , Attr.width size
        , Attr.height size
        , Attr.attribute "loading" "lazy"
        , css [ Tw.rounded_full, Tw.flex_shrink_0 ]
        ]
        []


{-| An author's avatar and name, linking to their page. If they have a bio, hovering or focusing shows it in a card.
-}
authorLink : Blog.Author -> Html msg
authorLink author =
    let
        showCard : Css.Style
        showCard =
            Global.descendants [ Global.selector "[data-author-card]" [ Tw.block ] ]
    in
    Html.span
        [ css
            [ Tw.relative
            , Tw.inline_block
            , Css.hover [ showCard ]
            , Css.pseudoClass "focus-within" [ showCard ]
            ]
        ]
        (a
            [ Attr.href (path (Route.Blog__Author__Login_ { login = String.toLower author.login }))
            , css [ Theming.quietLink, Tw.inline_flex, Tw.items_center, Tw.gap_2 ]
            ]
            [ avatar 20 author.login, text author.name ]
            :: (author.bio |> Maybe.map (\bio -> [ viewBioCard author bio ]) |> Maybe.withDefault [])
        )


viewBioCard : Blog.Author -> String -> Html msg
viewBioCard author bio =
    div [ Attr.attribute "data-author-card" "", css [ Tw.hidden, Tw.absolute, Tw.left_0, Tw.top_full, Tw.z_20, Tw.w_72, Tw.pt_2 ] ]
        [ div
            [ css
                [ Theming.bodyFont
                , Tw.bg_color Tw.dd_deepblueLighter
                , Tw.border
                , Tw.border_color Tw.dd_border
                , Tw.p_4
                , Tw.text_sm
                , Tw.leading_normal
                , Tw.text_color Tw.dd_text
                , Global.descendants
                    [ Global.typeSelector "p" [ Tw.m_0 ]
                    , Global.typeSelector "a" [ Tw.text_color Tw.dd_teal ]
                    ]
                ]
            ]
            [ div [ css [ Tw.flex, Tw.items_center, Tw.gap_3, Tw.mb_2 ] ]
                [ avatar 40 author.login
                , span [ css [ Tw.font_semibold ] ] [ text author.name ]
                ]
            , case Blog.renderBody "" [] bio of
                Ok rendered ->
                    div [] (List.map Html.fromUnstyled rendered)

                Err _ ->
                    text bio
            ]
        ]


{-| The authors and publish date as one centred row
-}
metaLine : List Blog.Author -> Maybe Time.Posix -> Html msg
metaLine authors published =
    div [ css [ Theming.bodyFont, Tw.flex, Tw.flex_wrap, Tw.items_center, Tw.gap_x_3, Tw.gap_y_1, Tw.text_color Tw.dd_subtle ] ]
        (List.concat
            [ List.map authorLink authors
            , published
                |> Maybe.map
                    (\date ->
                        [ span [ css [ Tw.w_1, Tw.h_1, Tw.rounded_full, Tw.bg_color Tw.dd_subtle ] ] []
                        , span [] [ text (Blog.formatDate date) ]
                        ]
                    )
                |> Maybe.withDefault []
            ]
        )


{-| A tag badge linking to the tag's page.
-}
tagLink : String -> Html msg
tagLink tag =
    a
        [ Attr.href (path (Route.Blog__Tag__Tag_ { tag = Blog.tagSlug tag }))
        , css [ Theming.bodyFont, Theming.badgeStyle Theming.Teal, Tw.text_sm, Tw.px_3, Tw.py_1, Tw.no_underline, Tw.relative ]
        ]
        [ text tag ]


{-| Post cards in the order given, or a note when there are none.
-}
viewPostList : List Blog.Summary -> Html msg
viewPostList posts =
    case posts of
        [] ->
            p [ css [ Theming.bodyFont, Tw.text_color Tw.dd_subtle ] ] [ text "No posts yet." ]

        _ ->
            div [ css [ Tw.flex, Tw.flex_col, Tw.gap_6 ] ] (List.map viewPost posts)


viewPost : Blog.Summary -> Html msg
viewPost post =
    Theming.cardShell [ Tw.relative, Tw.p_6, Tw.flex, Tw.flex_col, Tw.gap_3 ]
        [ Html.h2 [ css [ Theming.headingFont, Tw.text_2xl, Tw.font_semibold, Tw.m_0 ] ]
            [ a
                [ Attr.href (path (Route.Blog__Slug_ { slug = post.slug }))
                , css
                    [ Tw.no_underline
                    , Tw.text_color Tw.dd_text
                    , Css.after [ Css.property "content" "\"\"", Tw.absolute, Tw.inset_0 ]
                    ]
                ]
                [ text post.title ]
            ]
        , metaLine post.authors post.published
        , p [ css [ Theming.bodyFont, Tw.m_0, Tw.leading_relaxed ] ] [ text post.description ]
        , div [ css [ Tw.flex, Tw.flex_wrap, Tw.gap_2 ] ] (List.map tagLink post.tags)
        ]


path : Route.Route -> String
path route =
    UrlPath.toAbsolute (Route.toPath route)
