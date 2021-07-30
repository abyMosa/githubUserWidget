module Components.UI.SuggestInput exposing (..)

import Components.UI.Loader as Loader
import Html exposing (Html, div, input, li, text, ul)
import Html.Attributes exposing (..)
import Html.Events exposing (onBlur, onClick, onFocus, onInput)
import Task
import Extras.Html as HtmlExtras


type alias Model =
    { selected : Maybe String
    , isSearching : Bool
    , value : Maybe String
    , isFocused : Bool
    , isLoading : Bool
    }


type Msg
    = NoOp
    | OnChange String
    | OptionSelected String
    | Focused
    | Blurred


type alias Handlers msg =
    { tagger : Msg -> msg
    , onChange : String -> msg
    , optionSelected : String -> msg
    }


init : Model
init =
    Model Nothing False Nothing False False


update : Handlers msg -> Msg -> Model -> ( Model, Cmd msg )
update h msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        OnChange str ->
            ( { model
                | value = Just str
                , isSearching = True
              }
            , emit (h.onChange str)
            )

        OptionSelected suggestion ->
            ( { model
                | selected = Just suggestion
                , isSearching = False
                , value = Just suggestion
              }
            , emit (h.optionSelected suggestion)
            )

        Focused ->
            ( { model | isFocused = True }, Cmd.none )

        Blurred ->
            ( { model | isFocused = False }, Cmd.none )


view : Handlers msg -> Model -> List String -> Html msg
view h model suggestions =
    div
        [ class "filter-list"
        , classList
            [ ( "-has-value", (model.value |> Maybe.withDefault "" |> String.length) > 0 )
            , ( "filter-list--focused", model.isFocused )
            ]
        ]
        [ div []
            [ input
                [ onInput (OnChange >> h.tagger)
                , placeholder "Filter GitHub users"
                , value <| Maybe.withDefault "" model.value
                , onFocus (Focused |> h.tagger)
                , onBlur (Blurred |> h.tagger)
                ]
                []
            , Loader.linear model.isLoading
            ]
        , HtmlExtras.renderIf
            model.isSearching
            (div []
                [ suggestions
                    |> List.map
                        (\s ->
                            li
                                [ class "pointer"
                                , onClick (OptionSelected s |> h.tagger)
                                ]
                                [ text s ]
                        )
                    |> ul []
                ]
            )
        ]


emit : msg -> Cmd msg
emit msg =
    Task.attempt (always msg) (Task.succeed ())


setIsLoading : Bool -> Model -> Model
setIsLoading isLoading model =
    { model | isLoading = isLoading }