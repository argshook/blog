port module Pages.Blog.Post exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Markdown
import Navigation
import Pages.Blog.Date exposing (postDate)
import Pages.Blog.PostModel exposing (..)
import Pages.Blog.PostMsg exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadPost postId postMeta ->
            { initialModel
                | postId = postId
                , postMeta = postMeta
            }
                ! [ getPost postId ]

        PostLoaded ->
            model
                ! [ highlight "" ]

        ShowComments ->
            { model | isCommentsShown = True }
                ! [ blogPostCommentsEnabled model.postMeta.id ]

        PostFetch data ->
            case data of
                Ok post ->
                    let
                        model_ =
                            { model
                                | postContent = post
                                , isPostLoading = False
                            }
                    in
                        update PostLoaded model_

                Err _ ->
                    { model
                        | postContent = "Failed to fetch :("
                        , isPostLoading = False
                    }
                        ! []

        PostMetaFetch postsMeta ->
            case postsMeta of
                Ok metas ->
                    let
                        postMeta =
                            List.filter (\p -> p.slug == model.postId) metas
                                |> List.head
                                |> Maybe.withDefault initialPostMeta
                    in
                        { model | postMeta = postMeta } ! []

                Err _ ->
                    model ! []

        GoBack ->
            model ! [ Navigation.back 1 ]

        SetPostMeta postMeta ->
            { model | postMeta = postMeta } ! []


getPost : PostId -> Cmd Msg
getPost postId =
    let
        url =
            "Posts/" ++ postId ++ ".md"
    in
        Http.send PostFetch
            (Http.getString url)


view : Model -> Html Msg
view model =
    if model.isPostLoading then
        div [ class "blog-post blog-post--loading" ] [ text "Loading..." ]
    else
        div [ class "blog-post" ] <|
            [ postHeader model.postMeta
            , Markdown.toHtml [ class "blog-post-content" ] model.postContent
            ]
                ++ showCommentsBlock model


showCommentsBlock : Model -> List (Html Msg)
showCommentsBlock model =
    let
        commentsBlock : Bool -> Html Msg
        commentsBlock isShown =
            if isShown then
                div [ id "disqus_thread" ] []
            else
                button
                    [ onClick ShowComments
                    , class "card card--small"
                    ]
                    [ text "Show Comments" ]

        conditions =
            [ model.postMeta /= initialPostMeta
            , List.all (\s -> model.postMeta.slug /= s) [ "about", "projects" ]
            ]
    in
        if List.all (\c -> c) conditions then
            [ div
                [ class "blog-post-comments" ]
                [ commentsBlock model.isCommentsShown ]
            ]
        else
            []


postHeader : PostMeta -> Html Msg
postHeader postMeta =
    let
        { date, time } =
            postDate postMeta.dateCreated
    in
        div
            [ class "blog-post-header" ]
            [ button
                [ class "btn btn--as-link"
                , onClick GoBack
                ]
                [ text "« Back" ]
            , div
                [ class "blog-post-header-meta" ]
                [ span [ class "blog-post-header-meta__date" ] [ text date ]
                , span [ class "blog-post-header-meta__time" ] [ text time ]
                ]
            ]


port highlight : String -> Cmd msg


port blogPostCommentsEnabled : String -> Cmd msg
