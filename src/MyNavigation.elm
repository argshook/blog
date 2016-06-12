module MyNavigation exposing (..)

import String
import UrlParser exposing (Parser, (</>), format, int, oneOf, s, string)
import Navigation
import Model exposing (Model, initialModel)
import States exposing (..)
import Messages exposing (..)


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
  , format Forms (s "forms")
  , format Category (s "category")
  , format FizzBuzz (s "fizz-buzz")
  , format Blog (s "blog" </> string)
  ]


toUrl : State -> String
toUrl state =
  case state of
    Home -> "#"
    Binary -> "#binary"
    Forms -> "#forms"
    Category -> "#category"
    FizzBuzz -> "#fizz-buzz"
    Blog q ->
      "#blog/" ++ q


urlUpdate : Result String State -> Model -> (Model, Cmd Msg)
urlUpdate result model =
  case result of
    Ok newState ->
      case newState of
        _ ->
          let
              model' =
                { model | state = newState }
          in
              (model', Cmd.none)

    Err _ ->
      (model, Navigation.modifyUrl (toUrl model.state))

