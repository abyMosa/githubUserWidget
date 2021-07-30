module Extras.Html exposing (..)
import Html exposing (Html, text)


renderIf : Bool -> Html msg -> Html msg
renderIf bool html =
    if bool then
        html

    else
        text ""