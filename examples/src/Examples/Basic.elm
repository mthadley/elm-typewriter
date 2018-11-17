module Examples.Basic exposing (Model, Msg, init, update, view)

import Html.Styled exposing (Html)
import Layout
import Typewriter


type alias Model =
    Typewriter.Model


init : ( Model, Cmd Msg )
init =
    Typewriter.withWords [ "one", "two", "three" ]
        |> Typewriter.init
        |> Tuple.mapSecond (Cmd.map TypewriterMsg)


view : Model -> Html msg
view model =
    Layout.example
        { title = "Basic"
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
    Typewriter.withWords [ "one", "two", "three" ]
        |> Typewriter.init
    """
