module Pages.PagesView exposing (..)


import Html.App
import Html exposing (..)
import Html.Attributes exposing (..)
import Common exposing ((=>), colors)


import Pages.Age as Age
import Pages.Forms as Forms
import Pages.BinaryTree as BinaryTree
import Pages.CategoryTree as CategoryTree
import Pages.FizzBuzz as FizzBuzz
import Pages.Blog.Main as Blog
import Pages.Blog.PostsList as PostsList
import Pages.PagesMessages as PagesMessages
import Pages.PagesUpdate as PagesUpdate


import Pages.PagesModel exposing (..)
import Pages.PagesMessages exposing (..)
import States exposing (..)


view : Model -> State -> Html Msg
view model state =
  let
      component =
        case state of
          Home ->
            Html.App.map PostsListMsg (PostsList.view model.postsListModel)

          Forms ->
            div
              []
              [ Html.App.map PagesMessages.FormsMsg (Forms.view model.formsModel)
              , Html.App.map PagesMessages.AgeMsg (Age.view model.ageModel)
              ]

          Binary -> Html.App.map PagesMessages.BinaryTreeMsg (BinaryTree.view model.binaryTreeModel)
          Category -> Html.App.map PagesMessages.CategoryTreeMsg (CategoryTree.view model.categoryTreeModel)
          FizzBuzz -> Html.App.map PagesMessages.FizzBuzzMsg (FizzBuzz.view model.fizzBuzzModel)
          _ -> text "shit"
          --Blog n -> Blog.view model
  in
    div
      [ style [ "padding" => "30px 0 0" ] ]
      [ component ]

