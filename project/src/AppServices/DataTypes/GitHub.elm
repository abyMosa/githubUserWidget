module AppServices.DataTypes.GitHub exposing (..)


type UserName
    = UserName String


type alias User =
    { userName : UserName
    , name : Maybe String
    , avatarUrl : String
    , location : Maybe String
    , followers : Int
    , following : Int
    , publicRepos : Int
    }
