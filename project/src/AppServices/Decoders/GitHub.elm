module AppServices.Decoders.GitHub exposing (..)

import AppServices.DataTypes.GitHub exposing (User, UserName(..))
import Json.Decode as Decode exposing (Decoder, at, field, int, list, map, map7, maybe, string)



-- decoders


userNamesDecoder : Decoder (List UserName)
userNamesDecoder =
    at [ "items" ] (list userNameDecoder)


userNameDecoder : Decoder UserName
userNameDecoder =
    field "login" string |> map UserName


userDecoder : Decoder User
userDecoder =
    map7 User
        userNameDecoder
        (field "name" (maybe string))
        (field "avatar_url" string)
        (field "location" (maybe string))
        (field "followers" int)
        (field "following" int)
        (field "public_repos" int)


decodeBadStausBody : Decode.Decoder String
decodeBadStausBody =
    Decode.field "message" Decode.string
