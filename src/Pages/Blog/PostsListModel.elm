port module Pages.Blog.PostsListModel exposing (..)

import Json.Decode as Json exposing (field)
import Pages.Blog.PostModel exposing (..)
import Pages.Blog.PostsListMsg as PostsListMsg


type alias Model =
    { filter : String
    , posts : List PostMeta
    }


initialModel : Model
initialModel =
    { filter = ""
    , posts = []
    }


postsResponseDecoder : Json.Decoder (List PostMeta)
postsResponseDecoder =
    Json.at [ "posts" ] <|
        Json.list <|
            Json.map7 PostMeta
                (field "title" Json.string)
                (field "author" Json.string)
                (field "id" Json.string)
                (field "slug" Json.string)
                (field "path" Json.string)
                (Json.maybe (field "dateCreated" Json.int))
                (Json.maybe (field "dateModified" Json.int))


port posts : (List PostMeta -> msg) -> Sub msg


subscriptions : Model -> Sub PostsListMsg.Msg
subscriptions _ =
    posts PostsListMsg.LoadPosts
