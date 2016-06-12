module View exposing (view)

import Html.App
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String

import Common exposing ((=>), colors)
import Model exposing (..)
import Messages exposing (..)
import Pages.PagesView as PagesView
import States exposing (..)

view : Model -> Html Msg
view model =
  div
    [ style
      [ "width" => "700px"
      , "margin" => "0 auto"
      , "min-height" => "100vh"
      ]
    ]
    [ div
        [ style [ "padding" => "30px", "background" => colors.light ] ]
        [ h2
          []
          [ text "Elm experiments" ]
        , p
          []
          [ text "merely a sandbox to play with elm" ]
        ]
    , stateMenu model
    , Html.App.map PagesMessages (PagesView.view model.pagesModel model.state)
    ]


stateMenu : Model -> Html Msg
stateMenu model =
  let
      states =
        [ ("Home", Home)
        , ("Forms", Forms)
        , ("Binary", Binary)
        , ("Category", Category)
        , ("FizzBuzz", FizzBuzz)
        ]

      buttonStyle =
        [ "border" => ("1px solid " ++ colors.medium)
        , "border-radius" => "5px / 10px"
        , "padding" => "10px 25px"
        , "color" => colors.dark
        , "background" => "transparent"
        , "cursor" => "pointer"
        , "font-weight" => "bold"
        ]

      activeStyle state =
        let
            _ = Debug.log "state" (model.state)
        in
            if state == model.state then
              buttonStyle ++ [ "background" => colors.dark, "color" => colors.light ]
            else
              buttonStyle

      menuItem (name, state) =
        button
          [ onClick (ChangeState state)
          , style <| activeStyle state
          ]
          [ text name ]

      menuStyles =
        [ "display" => "flex"
        , "justify-content" => "space-around"
        , "padding" => "30px"
        , "background" => colors.light
        ]

  in
    div
      [ style menuStyles ]
      (List.map menuItem states)

