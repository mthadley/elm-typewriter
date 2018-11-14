module Examples.Times exposing (Model, Msg, init, update, view)

import Html.Styled exposing (Html)
import Layout
import Typewriter


type alias Model =
    Typewriter.Model


init : ( Model, Cmd Msg )
init =
    Typewriter.init
        { words = [ "First Phrase", "Last Phrase" ]
        , iterations = Typewriter.times 2
        }
        |> Tuple.mapSecond (Cmd.map TypewriterMsg)


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TypewriterMsg typewriterMsg ->
            Typewriter.update typewriterMsg model
                |> Tuple.mapSecond (Cmd.map TypewriterMsg)

        Replay ->
            Typewriter.restart model
                |> Tuple.mapSecond (Cmd.map TypewriterMsg)


code : String
code =
    """
    Typewriter.init
        { words = [ "First Phrase", "Last Phrase"]
        , iterationCount = Typewriter.times 2
        }
    """
