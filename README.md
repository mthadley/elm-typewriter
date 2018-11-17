# `elm-typewriter`

A tiny little library for creating those typewriter effects seen on many popular
websites. It follows the Elm Architecture, so you can easily embed it in your
own application.

Check out the [examples](https://mthadley.github.io/elm-typewriter/)!

Here's a quick one:

```elm
module Main exposing (main)

import Browser
import Html exposing (Html)
import Typewriter


type alias Model =
    Typewriter.Model


init : ( Model, Cmd Msg )
init =
    Typewriter.withWords [ "one", "two", "three" ]
        |> Typewriter.init


view : Model -> Html msg
view model =
    Html.h1 [] [ Html.text (Typewriter.view model) ]


type alias Msg =
    Typewriter.Msg


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> init
        , view = view
        , update = Typewriter.update
        , subscriptions = \_ -> Sub.none
        }
```
