module Typewriter exposing
    ( Model, Config, withWords, init, view, Msg, update
    , iterations, withTypeDelay, withBackspaceDelay, withJitter
    , Iterations, infinite, times
    , togglePlay, isPaused, isDone, restart
    )

{-| This module follows the Elm Architecture. If you are new, it's definitely a good
idea to start by reading the [Official Guide](https://guide.elm-lang.org/architecture/).


# Basics

@docs Model, Config, withWords, init, view, Msg, update


# Customizing

@docs iterations, withTypeDelay, withBackspaceDelay, withJitter
@docs Iterations, infinite, times


# Utilities

@docs togglePlay, isPaused, isDone, restart

-}

import List.Zipper as Zipper exposing (Zipper)
import Process
import Random exposing (Generator)
import Task



-- BASICS


{-| Opaque type representing the current state of the typewriter.
-}
type Model
    = Model
        { mode : Mode
        , words : Zipper String
        , currentIteration : Iterations
        , config : ConfigInfo
        , delayCoeff : Float
        }


type alias ConfigInfo =
    { words : List String
    , iterations : Iterations
    , typeDelay : Int
    , backspaceDelay : Int
    , jitter : Generator Float
    }


{-| The settings for the typewriter. You can create one of these using
[`withWords`](#withWords), and then customize it using functions like
[`iterations`](#iterations). You can then initialize your typewriter by
passing your `Config` to [`init`](#init).

    Typewriter.withWords [ "Supercalifragilisticexpialidocious" ]
        |> Typewriter.iterations (Typewriter.times 3)
        |> Typewriter.withTypeDelay 600
        |> Typewriter.withBackspaceDelay 10
        |> Typewriter.withJitter (Random.float 0.5 1.5)
        |> Typewriter.init

See [Customizing](#Customizing).

-}
type Config
    = Config ConfigInfo


{-| Initialize your typewriter [`Config`](#config) with the words you
want it to type. This is the only way to create a [`Config`](#Config)!
-}
withWords : List String -> Config
withWords words =
    Config
        { words = words
        , iterations = infinite
        , typeDelay = 100
        , backspaceDelay = 50
        , jitter = Random.float 0.8 1.2
        }


{-| Change the amount of time between each key typed. This should specified
in **milliseconds**.

Note that this only affects how fast characters are deleted, and not how fast they
are _deleted_. For that, see [`withBackspaceDelay`](#withBackspaceDelay).

-}
withTypeDelay : Int -> Config -> Config
withTypeDelay delay (Config config) =
    Config { config | typeDelay = delay }


{-| Change the amount of time between each character deleted. This should specified
in **milliseconds**.
-}
withBackspaceDelay : Int -> Config -> Config
withBackspaceDelay delay (Config config) =
    Config { config | backspaceDelay = delay }


{-| Provide a generator that produces floats, that will be used to calculate the delay
in the next step of the typing process. The float is used as a coefficient with the delay
configured for that step.

If generator produces `0.5`, then the next step will be twice as fast. Conversely, if it
were to produce `2.0`, then that next step will take twice as long.

    Typewriter.withWords [ "I'm", "All", "Over", "The", "Place" ]
        |> Typwriter.withJitter (Random.float 0.1 20)
        |> Typwriter.init

-}
withJitter : Generator Float -> Config -> Config
withJitter jitter (Config config) =
    Config { config | jitter = jitter }


{-| Controls how many times the typwriter will run through it's script
of words. By default it will type infinitely, but you can also constrain
it. See [`times`](#times).

    Typewriter.withWords [ "Type", "Forever" ]
        |> Typwriter.iterations Typewriter.infinite
        |> Typwriter.init

-}
iterations : Iterations -> Config -> Config
iterations value (Config config) =
    Config { config | iterations = value }


{-| Controls how many times the typewriter will play.
-}
type Iterations
    = Infinite
    | Times Int


{-| The typewriter will continuously type it's list of words, starting
from the beginning after it finishes it's last word.
-}
infinite : Iterations
infinite =
    Infinite


{-| The typewriter will go through it's list of words a specified
amount of times, and then stop. There is a minimum of at least one
iteration, so for any value `n` where `n < 1`, it will be treated as `1`.
-}
times : Int -> Iterations
times =
    Times << max 0


{-| Create a new typewriter model from some settings.

    Typewriter.withWords [ "Let's get typing!" ]
        |> Typwriter.init

See [`Config`](#Config) for more ways to customize it's behavior.

-}
init : Config -> ( Model, Cmd Msg )
init (Config config) =
    let
        model =
            Model
                { mode = Typing 0
                , words = Zipper.fromList config.words |> Zipper.withDefault ""
                , config = config
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


{-| The view function. We just give you the String, so you can render it in
whatever way makes sense for your application.
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
schedule (Model { mode, config, delayCoeff }) =
    let
        stepAfter interval =
            Process.sleep (interval * delayCoeff)
                |> Task.perform (\_ -> NextStep)
                |> (\cmd ->
                        Cmd.batch
                            [ cmd
                            , Random.generate UpdateCoeff config.jitter
                            ]
                   )
    in
    case mode of
        Typing _ ->
            stepAfter (toFloat config.typeDelay)

        FinishedWord ->
            stepAfter 300

        Deleting _ ->
            stepAfter (toFloat config.backspaceDelay)

        Next ->
            stepAfter 500

        Done _ ->
            Cmd.none

        Paused _ ->
            Cmd.none



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

    Typewriter.withWords [ "Type", "Forever" ]
        |> Typwriter.init
        |> Typewriter.isPaused
        |> Expect.equal False

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
                    , currentIteration = info.config.iterations
                }
    in
    ( model, schedule model )
