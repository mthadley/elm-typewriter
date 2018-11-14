module Typewriter exposing
    ( Model, Config, init, view, Msg, update
    , IterationCount, infinite, times
    , togglePlay, isPaused, isDone, restart
    )

{-|


# Basics

@docs Model, Config, init, view, Msg, update


# Controlling Iterations

@docs IterationCount, infinite, times


# Utilities

@docs togglePlay, isPaused, isDone, restart

-}

import List.Zipper as Zipper exposing (Zipper)
import Process
import Random
import Task



-- BASICS


{-| Opaque type representing the current state of the typewriter.
-}
type Model
    = Model
        { mode : Mode
        , words : Zipper String
        , currentIteration : IterationCount
        , iterations : IterationCount
        , delayCoeff : Float
        }


{-| The settings for the typewriter.

`iterations` can be used to control how many times the typewriter will
play. See [`IterationCount`](#IterationCount).

-}
type alias Config =
    { words : List String
    , iterations : IterationCount
    }


{-| Controls how many times the typewriter will play.
-}
type IterationCount
    = Infinite
    | Times Int


{-| The typewriter will continuously type it's list of words, starting
from the beginning after it finishes it's last word.
-}
infinite : IterationCount
infinite =
    Infinite


{-| The typewriter will go through it's list of words a specified
amount of times, and then stop. There is a minimum of at least one
iteration, so for any value `n` where `n < 1`, it will be treated as `1`.
-}
times : Int -> IterationCount
times =
    Times << max 1


{-| Create a new typewriter model from some settings. See [`Config`](#Config).

    Typewriter.init
        { words = [ "First", "Second", "Third" ]
        , iterations = Typewriter.infinite
        }

-}
init : Config -> ( Model, Cmd Msg )
init config =
    let
        model =
            Model
                { mode = Typing 0
                , words = Zipper.fromList config.words |> Zipper.withDefault ""
                , iterations = config.iterations
                , currentIteration = config.iterations
                , delayCoeff = 1
                }
    in
    ( model, schedule model )


type Mode
    = Typing Int
    | FinishedWord
    | Deleting Int
    | Next
    | Done String
    | Paused Mode


{-| The type of messages that typewriters emit.
-}
type Msg
    = NextStep
    | UpdateCoeff Float


{-| Make sure to call this `update` in your own `update` to make
the typewriter type!
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg ((Model info) as model) =
    case msg of
        NextStep ->
            ( nextStep model, schedule model )

        UpdateCoeff coeff ->
            ( Model { info | delayCoeff = coeff }, Cmd.none )


nextStep : Model -> Model
nextStep (Model info) =
    Model <|
        case info.mode of
            Typing count ->
                if count < currentWordLength info.words then
                    { info | mode = Typing (count + 1) }

                else
                    case ( info.currentIteration, Zipper.next info.words ) of
                        ( Times 1, Nothing ) ->
                            { info | mode = Done <| Zipper.current info.words }

                        _ ->
                            { info | mode = FinishedWord }

            FinishedWord ->
                { info | mode = Deleting 0 }

            Deleting count ->
                if count < currentWordLength info.words then
                    { info | mode = Deleting (count + 1) }

                else
                    { info | mode = Next }

            Next ->
                case Zipper.next info.words of
                    Nothing ->
                        { info
                            | words = Zipper.first info.words
                            , mode = Typing 0
                            , currentIteration =
                                case info.currentIteration of
                                    Infinite ->
                                        Infinite

                                    Times n ->
                                        Times (n - 1)
                        }

                    Just newWords ->
                        { info | words = newWords, mode = Typing 0 }

            Done _ ->
                info

            Paused _ ->
                info


currentWordLength : Zipper String -> Int
currentWordLength =
    String.length << Zipper.current


{-| The view function. Make sure to pass the model here!
-}
view : Model -> String
view (Model ({ mode, words } as info)) =
    case mode of
        Typing count ->
            String.left count <| Zipper.current words

        FinishedWord ->
            Zipper.current words

        Deleting count ->
            String.dropRight count <| Zipper.current words

        Next ->
            ""

        Done last ->
            last

        Paused pausedMode ->
            view <| Model <| { info | mode = pausedMode }


schedule : Model -> Cmd Msg
schedule (Model { mode, delayCoeff }) =
    let
        stepAfter interval =
            Process.sleep (interval * delayCoeff)
                |> Task.perform (\_ -> NextStep)
                |> (\cmd -> Cmd.batch [ cmd, randomCoeff ])
    in
    case mode of
        Typing _ ->
            stepAfter 100

        FinishedWord ->
            stepAfter 300

        Deleting _ ->
            stepAfter 50

        Next ->
            stepAfter 500

        Done _ ->
            Cmd.none

        Paused _ ->
            Cmd.none


randomCoeff : Cmd Msg
randomCoeff =
    Random.float 0.8 1.2
        |> Random.generate UpdateCoeff



-- UTILITIES


{-| Toggles the playing state of the typewriter. If it is currently playing,
then this will pause it. If it is already paused, then it will resume playing.
You can check if it is currently paused or playing using [`isPaused`](#isPaused).
-}
togglePlay : Model -> ( Model, Cmd Msg )
togglePlay (Model info) =
    case info.mode of
        Paused mode ->
            let
                model =
                    Model { info | mode = mode }
            in
            ( model, schedule model )

        mode ->
            ( Model { info | mode = mode }, Cmd.none )


{-| Returns true if the typewriter is paused.
-}
isPaused : Model -> Bool
isPaused (Model { mode }) =
    case mode of
        Paused _ ->
            True

        _ ->
            False


{-| Retuorns true if this typewriter has no more things to type! This
will never return false if the [`iterations`](#Config) was set to
infinite.
-}
isDone : Model -> Bool
isDone (Model { mode }) =
    case mode of
        Done _ ->
            True

        Paused (Done _) ->
            True

        _ ->
            False


{-| Sets the typewriter back to it's original state. Useful if you have
a typewriter that is "done", and you want it to start typing from the
beginning.
-}
restart : Model -> ( Model, Cmd Msg )
restart (Model info) =
    let
        model =
            Model
                { info
                    | words = Zipper.first info.words
                    , mode = Typing 0
                    , currentIteration = info.iterations
                }
    in
    ( model, schedule model )
