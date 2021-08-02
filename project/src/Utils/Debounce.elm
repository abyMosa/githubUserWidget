module Utils.Debounce exposing (Debounce(..), Msg, event, init, push, update)

import Process
import Task


type Debounce msg
    = Debounce Int (List msg)


type Msg msg
    = EmitIfSettled Int
    | Push msg


init : Int -> Debounce msg
init cooldown =
    Debounce cooldown []


event : (Msg msg -> msg) -> msg -> msg
event tagger msg =
    tagger (Push msg)


{-|

    Pushing message directly to the queue from update fn

    Useful if we want to capture the event and maybe update our model while limiting the effects

    Text input for example, we might want to prevent calling the api on every key stroke but we want
    to update our state with the new value of the input, otherwise we could lose what the user inputed.

    If we dont care about the new information comming with the event, then better use the event function
    at the source at html as msg

-}
push : (Msg msg -> msg) -> msg -> Debounce msg -> ( Debounce msg, Cmd msg )
push tagger msg (Debounce cooldown queue) =
    ( Debounce cooldown (msg :: queue)
    , emitAfter cooldown (tagger <| EmitIfSettled (List.length queue + 1))
    )


{-| Debounce internal Msgs
-}
update : (Msg msg -> msg) -> Msg msg -> Debounce msg -> ( Debounce msg, Cmd msg )
update tagger internalMsg ((Debounce cooldown queue) as debounce) =
    case internalMsg of
        EmitIfSettled msgCount ->
            if List.length queue == msgCount then
                ( Debounce cooldown []
                , List.head queue
                    |> Maybe.map emit
                    |> Maybe.withDefault Cmd.none
                )

            else
                ( debounce, Cmd.none )

        Push msg ->
            ( Debounce cooldown (msg :: queue)
            , emitAfter cooldown (tagger <| EmitIfSettled (List.length queue + 1))
            )



-- Emitting messages


emitAfter : Int -> msg -> Cmd msg
emitAfter delay msg =
    toFloat delay
        |> Process.sleep
        |> Task.perform (always msg)


emit : msg -> Cmd msg
emit msg =
    Task.succeed msg
        |> Task.perform identity
