module Examples.Times exposing (Model, Msg, init, subscriptions, update, view)

import Examples.Layout as Layout
import Html.Styled exposing (Html)
import Typewriter


type alias Model =
    Typewriter.Model


init : Model
init =
    Typewriter.init
        { words = [ "First Phrase", "Last Phrase" ]
        , iterationCount = Typewriter.times 2
        }


view : Model -> Html Msg
view model =
    Layout.example
        { title = "Fixed Iterations"
        , buttons =
            [ { label = "Replay"
              , disabled = not (Typewriter.isDone model)
              , onClick = Replay
              }
            ]
        , code = code
        , text = Typewriter.view model
        }


type Msg
    = TypewriterMsg Typewriter.Msg
    | Replay


update : Msg -> Model -> Model
update msg model =
    case msg of
        TypewriterMsg typewriterMsg ->
            Typewriter.update typewriterMsg model

        Replay ->
            Typewriter.restart model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map TypewriterMsg <| Typewriter.subscriptions model


code : String
code =
    """
    Typewriter.init
        { words = [ "First Phrase", "Last Phrase"]
        , iterationCount = Typewriter.times 2
        }
    """
