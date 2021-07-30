module Components.UI.Loader exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (classList)


linear : Bool -> Html msg
linear isLoading =
    div
        [ classList
            [ ( "ab-linear-loader", True )
            , ( "ab-linear-loader--show", isLoading )
            ]
        ]
        []