module Examples.Times exposing (Model, Msg, init, update, view)

import Html.Styled exposing (Html)
import Layout
import Typewriter


type alias Model =
    Typewriter.Model


init : ( Model, Cmd Msg )
init =
    Typewriter.withWords [ "First Phrase", "Last Phrase" ]
        |> Typewriter.iterations (Typewriter.times 2)
        |> Typewriter.init
        |> Tuple.mapSecond (Cmd.map TypewriterMsg)


view : Model -> Html Msg
view model =
    Layout.example
        { title = "Just a Few"
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
    Typewriter.withWords [ "First Phrase", "Last Phrase" ]
        |> Typewriter.iterations (Typewriter.times 2)
        |> Typewriter.init
    """
