module MyNavigation exposing (..)

import String
import UrlParser exposing (Parser, (</>), format, int, oneOf, s, string)
import Navigation
import Model exposing (Model, initialModel)
import States exposing (..)
import Messages exposing (..)
import Task

import Pages.PagesUpdate
import Pages.PagesMessages
import Pages.Blog.PostMsg as PostMsg
import Pages.Blog.PostsListMsg as PostsListMsg


init : Result String State -> ( Model, Cmd Msg )
init result =
  urlUpdate result initialModel


urlParser : Navigation.Parser (Result String State)
urlParser =
  Navigation.makeParser (fromUrl << .hash)


fromUrl : String -> Result String State
fromUrl hash =
  UrlParser.parse identity pageParser (String.dropLeft 1 hash)


pageParser : Parser (State -> a) a
pageParser =
  oneOf
  [ format Home (s "")
  , format Binary (s "binary")
  , format Minesweeper (s "minesweeper")
  , format Category (s "category")
  , format FizzBuzz (s "fizz-buzz")
  , format Blog (s "blog" </> string)
  ]


toUrl : State -> String
toUrl state =
  case state of
    Home -> "#"
    Binary -> "#binary"
    Minesweeper -> "#minesweeper"
    Category -> "#category"
    FizzBuzz -> "#fizz-buzz"
    Blog q -> "#blog/" ++ q


-- TODO: too much login in here IMO, need to split somehow
-- is this even the way to go? I'm "sending" initial
-- message for pages here.
urlUpdate : Result String State -> Model -> (Model, Cmd Msg)
urlUpdate result model =
  case result of
    Ok newState ->
      case newState of
        States.Home ->
          let
              (homeModel, homeCmd) =
                Pages.PagesUpdate.update
                  (Pages.PagesMessages.PostsListMsg (PostsListMsg.LoadPosts))
                  model.pagesModel
          in
              { model | state = newState } ! [ Cmd.map PagesMessages homeCmd ]

        States.Blog id ->
          let
              (pagesModel, pagesCmd) =
                Pages.PagesUpdate.update
                  (Pages.PagesMessages.PostMsg (PostMsg.LoadPost id))
                  model.pagesModel

          in
              { model
              | state = newState
              , pagesModel = pagesModel
              } !
              [ Cmd.map PagesMessages pagesCmd ]

        _ ->
          { model | state = newState } ! []

    Err _ ->
      (model, Navigation.modifyUrl (toUrl model.state))


