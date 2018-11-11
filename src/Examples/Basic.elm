module Examples.Basic exposing (Model, Msg, init, subscriptions, update, view)

import Examples.Layout as Layout
import Html.Styled exposing (Html)
import Typewriter


type alias Model =
    Typewriter.Model


init : Model
init =
    Typewriter.init
        { words = [ "one", "two", "three" ]
        , iterationCount = Typewriter.infinite
        }


view : Model -> Html Msg
view model =
    Layout.example
        { title = "Basic"
        , buttons = []
        , code = code
        , text = Typewriter.view model
        }


type Msg
    = TypewriterMsg Typewriter.Msg


update : Msg -> Model -> Model
update msg model =
    case msg of
        TypewriterMsg typewriterMsg ->
            Typewriter.update typewriterMsg model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map TypewriterMsg <| Typewriter.subscriptions model


code : String
code =
    """
    Typewriter.init
        { words = ["one", "two", "three"]
        , iterationCount = Typewriter.infinite
        }
    """
