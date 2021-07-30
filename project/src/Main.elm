module Main exposing (..)

import Browser
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src)
import Components.GitHubWidget as GitHubWidget



---- MODEL ----


type alias Model =
    {gitHubWidget : GitHubWidget.Model}


init : ( Model, Cmd Msg )
init =
    ( Model GitHubWidget.init, Cmd.none )



---- UPDATE ----


type Msg
    = GitHubWidgetMsg GitHubWidget.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GitHubWidgetMsg subMsg -> 
            GitHubWidget.update subMsg model.gitHubWidget
                |> Tuple.mapFirst Model
                |> Tuple.mapSecond (Cmd.map GitHubWidgetMsg)




---- VIEW ----


view : Model -> Html Msg
view {gitHubWidget} =
    div []
        [ GitHubWidget.view gitHubWidget 
            |> Html.map GitHubWidgetMsg
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
