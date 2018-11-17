module Examples.Jitter exposing (Model, Msg, init, update, view)

import Html.Styled exposing (Html)
import Layout
import Random
import Random.Extra
import Typewriter


type alias Model =
    Typewriter.Model


init : ( Model, Cmd Msg )
init =
    Typewriter.withWords [ "Maybe I drank too much soda this morning..." ]
        |> Typewriter.withJitter
            (Random.Extra.frequency
                ( 10, Random.constant 1 )
                [ ( 1, Random.constant 15 ) ]
            )
        |> Typewriter.init
        |> Tuple.mapSecond (Cmd.map TypewriterMsg)


view : Model -> Html msg
view model =
    Layout.example
        { title = "Hiccups"
        , buttons = []
        , code = code
        , text = Typewriter.view model
        }


type Msg
    = TypewriterMsg Typewriter.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TypewriterMsg typewriterMsg ->
            Typewriter.update typewriterMsg model
                |> Tuple.mapSecond (Cmd.map TypewriterMsg)


code : String
code =
    """
    Typewriter.withWords [ "Maybe I drank too much soda this morning..." ]
        |> Typewriter.withJitter
            (Random.Extra.frequency
                ( 10, Random.constant 1 )
                [ ( 1, Random.constant 15 ) ]
            )
        |> Typewriter.init
    """
