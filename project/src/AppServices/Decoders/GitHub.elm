module AppServices.Decoders.GitHub exposing (..)

import AppServices.DataTypes.GitHub exposing (UserName(..), User)
import Json.Decode as Decode


-- decoders


userNameDecoder : Decode.Decoder UserName
userNameDecoder =
    Decode.field "login" Decode.string
        |> Decode.map UserName


userDecoder : Decode.Decoder User
userDecoder =
    Decode.map7 User
        userNameDecoder
        (Decode.field "name" (Decode.maybe Decode.string))
        (Decode.field "avatar_url" Decode.string)
        (Decode.field "location" (Decode.maybe Decode.string))
        (Decode.field "followers" Decode.int)
        (Decode.field "following" Decode.int)
        (Decode.field "public_repos" Decode.int)

