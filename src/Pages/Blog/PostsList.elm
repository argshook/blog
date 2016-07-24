module Pages.Blog.PostsList exposing (..)

import Navigation
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Task
import Http
import Json.Decode as Json exposing ((:=))
import String

import Pages.PagesMessages as PagesMessages
import Pages.Blog.PostsListMsg exposing (..)
import Pages.Blog.PostsListModel exposing (..)
import Pages.Blog.PostModel exposing (Post)
import Pages.Blog.PostMsg as PostMsg


update : Msg -> Model -> (Model, Cmd Msg, Cmd PagesMessages.Msg)
update msg model =
  case msg of
    Filter newFilter ->
      ({ model | filter = newFilter }, Cmd.none, Cmd.none)

    OpenPost post ->
      ( model
      , Navigation.newUrl ("#blog/" ++ post.slug)
      , Task.succeed (PostMsg.SetPostMeta post) |>
          Task.perform PagesMessages.PostMsg PagesMessages.PostMsg
      )

    LoadPosts ->
      (model, loadPosts, Cmd.none)

    LoadPostsSuccess posts ->
      ({ model | posts = posts }, Cmd.none, Cmd.none)

    LoadPostFail err ->
      let
          _ = Debug.log "failed to fetch all posts" err
      in
          (model, Cmd.none, Cmd.none)


loadPosts : Cmd Msg
loadPosts =
  let
      url =
        "db.json"

      responseDecoder : Json.Decoder (List Post)
      responseDecoder =
        Json.at ["posts"]
          <| Json.list
          <| Json.object7 Post
            ("title" := Json.string)
            ("author" := Json.string)
            ("id" := Json.string)
            ("slug" := Json.string)
            ("path" := Json.string)
            (Json.maybe ("dateCreated" := Json.int))
            (Json.maybe ("dateModified" := Json.int))
  in
      Task.perform LoadPostFail LoadPostsSuccess (Http.get responseDecoder url)

filteredPosts : Model-> List (Html Msg)
filteredPosts model =
  List.map (\p -> postCard p )
    <| if String.length model.filter /= 0 then
        List.filter
          (\p -> String.contains (String.toLower model.filter) (String.toLower p.title))
          model.posts
       else
         model.posts


view : Model -> Html Msg
view model =
    div
      [ class "blog" ]
      [ div
        [ class "blog-posts-filter" ]
        [ text "Filter posts "
        , input
            [ onInput Filter
            , placeholder "Filter posts"
            , value model.filter
            , class "input"
            ]
            []
        ]
      , div [ class "blog-posts-list" ] (filteredPosts model)
      ]


postCard : Post -> Html Msg
postCard post =
  a
    [ class "blog-post-card"
    , onClick (OpenPost post)
    ]
    [ text post.title ]

