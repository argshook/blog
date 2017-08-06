module Update exposing (..)

import Messages exposing (..)
import Model exposing (..)
import MyNavigation exposing (..)
import Navigation
import Pages.Blog.PostMsg
import Pages.Blog.PostModel
import Pages.PagesMessages
import Pages.PagesUpdate
import States
import UrlParser


update : Messages.Msg -> Model -> ( Model, Cmd Messages.Msg )
update msg model =
    case msg of
        PagesMessages msg ->
            let
                ( model_, cmd ) =
                    Pages.PagesUpdate.update msg model.pagesModel
            in
                ( { model | pagesModel = model_ }, Cmd.map PagesMessages cmd )

        ChangeState newState ->
            { model | state = newState } ! [ Navigation.newUrl (toUrl newState) ]

        UrlChange location ->
            let
                newState =
                    UrlParser.parseHash MyNavigation.pageParser location
                        |> Maybe.withDefault States.Home

                openPostMsg : String -> List Pages.Blog.PostModel.PostMeta -> Pages.PagesMessages.Msg
                openPostMsg slug postsList =
                    let
                        postMeta =
                            List.filter (\meta -> meta.slug == slug) postsList
                                |> List.head
                                |> Maybe.withDefault Pages.Blog.PostModel.initialPostMeta
                    in
                        Pages.PagesMessages.PostMsg (Pages.Blog.PostMsg.LoadPost slug postMeta)

                ( pagesModel, pagesCmd ) =
                    case newState of
                        States.Blog slug ->
                            Pages.PagesUpdate.update (openPostMsg slug model.pagesModel.postsListModel.posts) model.pagesModel

                        _ ->
                            ( model.pagesModel, Cmd.none )
            in
                { model
                    | history = location :: model.history
                    , pagesModel = pagesModel
                    , state = newState
                }
                    ! [ Cmd.map PagesMessages pagesCmd ]
