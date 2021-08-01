module AppServices.Services.GitHub exposing (..)

import AppServices.DataTypes.GitHub exposing (User, UserName(..))
import AppServices.Decoders.GitHub as GitHubDecoders
import Extras.Http
import Http



-- services


searchUsers : (Result Extras.Http.Error (List UserName) -> msg) -> String -> Cmd msg
searchUsers tagger query =
    Http.get
        { url = "https://api.github.com/search/users?q=" ++ query
        , expect = Extras.Http.expectJson tagger GitHubDecoders.userNamesDecoder
        }


fetchUser : (Result Extras.Http.Error User -> msg) -> UserName -> Cmd msg
fetchUser tagger (UserName userName) =
    Http.get
        { url = "https://api.github.com/users/" ++ userName
        , expect = Extras.Http.expectJson tagger GitHubDecoders.userDecoder
        }
