module Extras.Http exposing (Error(..), ErrorResolver(..), errToString, expectJson, jsonResolver, resolve)

{-| When migrating from elm/http 1.0.0 to 2.0.0 the `BadStatus` Error value had body content removed. This is a re-write
of the resolvers from the 1.0.0 library to allow access to the body of a BadStatus error

@docs Error, ErrorResolver, errToString, expectJson, jsonResolver, resolve

-}

import Http
import Json.Decode as Decode exposing (Decoder)


{-| A custom implementation of Http.Error to include response body in BadStatus
-}
type Error
    = BadUrl String
    | Timeout
    | NetworkError
    | BadStatus Int String
    | BadBody String


{-|

    - Server error resolver
    - accepts Err decoder and a function that transform the error to String

-}
type ErrorResolver err
    = ErrorResolver (Decoder err) (err -> String)


{-| -}
errToString : Error -> Maybe (ErrorResolver err) -> String
errToString err maybeErrorResolver =
    "Http.Error "
        ++ (case err of
                BadUrl msg ->
                    "BadUrl: " ++ msg

                Timeout ->
                    "Timeout: request timed out"

                NetworkError ->
                    "NetworkError: is your internet connection working?"

                BadStatus _ body ->
                    maybeErrorResolver
                        |> Maybe.map (resolveErr body)
                        |> Maybe.withDefault ("BadStatus: " ++ body)

                BadBody msg ->
                    "BadBody: " ++ msg
           )


resolveErr : String -> ErrorResolver err -> String
resolveErr errJson (ErrorResolver decoder toStrFn) =
    case Decode.decodeString decoder errJson of
        Ok err ->
            toStrFn err

        Err _ ->
            "BadStatus: " ++ errJson


{-| -}
expectJson : (Result Error a -> msg) -> Decoder a -> Http.Expect msg
expectJson toMsg decoder =
    Http.expectStringResponse toMsg <|
        resolve <|
            \string ->
                Result.mapError Decode.errorToString (Decode.decodeString decoder string)


{-| -}
jsonResolver : Decoder a -> Http.Resolver Error a
jsonResolver decoder =
    Http.stringResolver <|
        resolve <|
            \string ->
                Result.mapError Decode.errorToString (Decode.decodeString decoder string)


{-| -}
resolve : (String -> Result String a) -> Http.Response String -> Result Error a
resolve toResult response =
    case response of
        Http.BadUrl_ url ->
            Err (BadUrl url)

        Http.Timeout_ ->
            Err Timeout

        Http.NetworkError_ ->
            Err NetworkError

        Http.BadStatus_ metadata body ->
            Err (BadStatus metadata.statusCode body)

        Http.GoodStatus_ _ body ->
            Result.mapError BadBody (toResult body)
