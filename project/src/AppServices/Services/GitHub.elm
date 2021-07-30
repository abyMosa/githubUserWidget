module AppServices.Services.GitHub exposing (..)

import AppServices.DataTypes.GitHub exposing (UserName(..), User)
import AppServices.Decoders.GitHub as GitHubDecoders
import Json.Decode as Decode
import Http 

-- services


searchUsers : (Result Http.Error (List UserName) -> msg) -> String -> Cmd msg
searchUsers tagger query =
    Http.get
        { url = "https://api.github.com/search/users?q=" ++ query
        , expect = Http.expectJson tagger (Decode.at [ "items" ] (Decode.list GitHubDecoders.userNameDecoder))
        }


fetchUser : (Result Http.Error User -> msg) -> UserName -> Cmd msg
fetchUser tagger (UserName userName) =
    Http.get
        { url = "https://api.github.com/users/" ++ userName
        , expect = Http.expectJson tagger GitHubDecoders.userDecoder
        }
