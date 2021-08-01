module Components.GitHubWidget exposing (..)

import AppServices.DataTypes.GitHub exposing (User, UserName(..))
import AppServices.Decoders.GitHub exposing (decodeBadStausBody)
import AppServices.Services.GitHub as GitHubServices exposing (..)
import Components.UI.SuggestInput as SuggestInput exposing (..)
import Extras.Html as HtmlExtras
import Extras.Http exposing (ErrorResolver(..))
import Html exposing (Html, div, h2, h3, img, p, text)
import Html.Attributes exposing (class, src)
import Http exposing (..)


type alias Model =
    { suggestInput : SuggestInput.Model
    , userNames : List UserName
    , selectedUser : Maybe User
    , error : Maybe String
    }


type Msg
    = NoOp
    | FilterListMsg SuggestInput.Msg
    | GotUsers (Result Extras.Http.Error (List UserName))
    | FilteredListChanged String
    | UserNameSelected String
    | FetchedUser (Result Extras.Http.Error User)


suggestInputHandlers : SuggestInput.Handlers Msg
suggestInputHandlers =
    { tagger = FilterListMsg
    , onChange = FilteredListChanged
    , optionSelected = UserNameSelected
    }


init : Model
init =
    Model SuggestInput.init [] Nothing Nothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FilterListMsg filterListMsg ->
            SuggestInput.update suggestInputHandlers filterListMsg model.suggestInput
                |> Tuple.mapFirst (\m -> { model | suggestInput = m })

        GotUsers res ->
            case res of
                Ok userNames ->
                    ( { model
                        | userNames = List.take 3 userNames
                        , error =
                            case userNames of
                                [] ->
                                    Just "No User Found with this query, please try a different username!!"

                                _ ->
                                    Nothing
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( { model
                        | error =
                            Just (ErrorResolver decodeBadStausBody identity)
                                |> Extras.Http.errToString err
                                |> Just
                      }
                    , Cmd.none
                    )

        FilteredListChanged q ->
            if String.length q < 2 then
                ( { model | userNames = [] }
                , Cmd.none
                )

            else
                ( model, GitHubServices.searchUsers GotUsers q )

        UserNameSelected userName ->
            ( { model | suggestInput = SuggestInput.setIsLoading True model.suggestInput }
            , GitHubServices.fetchUser FetchedUser (UserName userName)
            )

        FetchedUser response ->
            case response of
                Ok user ->
                    ( { model
                        | selectedUser = Just user
                        , suggestInput = SuggestInput.setIsLoading False model.suggestInput
                        , error = Nothing
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( { model
                        | suggestInput = SuggestInput.setIsLoading False model.suggestInput
                        , error = Extras.Http.errToString err Nothing |> Just
                      }
                    , Cmd.none
                    )


view : Model -> Html Msg
view model =
    div [ class "Page page-about fh" ]
        [ div [ class "github-widget" ]
            [ div [ class "github-widget__inner" ]
                [ div [ class "github-widget__content-wrapper" ]
                    [ model.userNames
                        |> List.map userNameToString
                        |> SuggestInput.view suggestInputHandlers model.suggestInput
                    , model.error
                        |> Maybe.map renderErrorMessage
                        |> Maybe.withDefault (text "")
                    , HtmlExtras.renderIf (model.error == Nothing)
                        (model.selectedUser
                            |> Maybe.map renderSelectedUser
                            |> Maybe.withDefault (text "")
                        )
                    ]
                ]
            ]
        ]


renderSelectedUser : User -> Html Msg
renderSelectedUser { userName, name, avatarUrl, location, followers, following, publicRepos } =
    div [ class "github-widget__results" ]
        [ div [ class "github-widget__image-wrapper" ]
            [ img [ src avatarUrl ] []
            , h2 []
                [ name
                    |> Maybe.map text
                    |> Maybe.withDefault (text <| userNameToString userName)
                ]
            , h3 []
                [ text <|
                    Maybe.withDefault "I Live in my mind" location
                ]
            ]
        , div [ class "github-widget__footer" ]
            [ renderFooterColumn "Followers" followers
            , renderFooterColumn "Repository" publicRepos
            , renderFooterColumn "Following" following
            ]
        ]


renderFooterColumn : String -> Int -> Html Msg
renderFooterColumn label int =
    div []
        [ h2 [] [ text <| String.fromInt int ]
        , p [] [ text label ]
        ]


renderErrorMessage : String -> Html msg
renderErrorMessage err =
    div [ class "http-error" ]
        [ p [] [ text err ]
        ]



-- helpers


userNameToString : UserName -> String
userNameToString (UserName str) =
    str
