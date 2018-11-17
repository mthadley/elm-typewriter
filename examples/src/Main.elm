module Examples.Main exposing (main)

import Browser
import Css exposing (auto, hex, pct, px, qt, solid, vh, zero)
import Css.Global exposing (global, html)
import Examples.Basic as Basic
import Examples.Delay as Delay
import Examples.Jitter as Jitter
import Examples.Times as Times
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Layout
import Theme as Theme
import Typewriter


type alias Model =
    { title : Typewriter.Model
    , basic : Basic.Model
    , times : Times.Model
    , delay : Delay.Model
    , jitter : Jitter.Model
    }


init : ( Model, Cmd Msg )
init =
    let
        ( title, titleCmd ) =
            Typewriter.withWords
                [ "A Small Library!"
                , "Written In Elm!"
                , "Not Another JS Framework"
                , "Not Made With Love"
                ]
                |> Typewriter.init

        ( basic, basicCmd ) =
            Basic.init

        ( times, timesCmd ) =
            Times.init

        ( delay, delayCmd ) =
            Delay.init

        ( jitter, jitterCmd ) =
            Jitter.init
    in
    ( { title = title
      , basic = basic
      , times = times
      , delay = delay
      , jitter = jitter
      }
    , Cmd.batch
        [ Cmd.map TitleMsg titleCmd
        , Cmd.map BasicMsg basicCmd
        , Cmd.map TimesMsg timesCmd
        , Cmd.map DelayMsg delayCmd
        , Cmd.map JitterMsg jitterCmd
        ]
    )


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.styled Html.main_
            [ Css.maxWidth (px 760)
            , Css.margin2 (px 20) auto
            ]
            []
            [ global
                [ html
                    [ Css.minHeight (vh 100)
                    , Css.backgroundColor Theme.secondary
                    , Css.color Theme.primary
                    , Css.fontFamilies [ qt "IBM Plex Mono", .value Css.monospace ]
                    ]
                ]
            , Html.styled Html.div
                [ Css.border3 (px 4) solid Theme.primary
                , Css.height (pct 100)
                , Css.marginBottom (px 20)
                , Theme.borderRadius
                ]
                []
                [ viewTitle model
                , Html.styled Html.div
                    [ Css.padding2 zero (px 12) ]
                    []
                    [ Basic.view model.basic
                    , Html.map TimesMsg <| Times.view model.times
                    , Delay.view model.delay
                    , Jitter.view model.jitter
                    ]
                ]
            ]
        , Html.styled Html.footer
            [ Css.textAlign Css.center ]
            []
            [ Html.small []
                [ Html.styled Html.a
                    [ Css.color Theme.accent ]
                    [ Attr.href "https://github.com/mthadley/elm-typewriter" ]
                    [ Html.text "Github" ]
                ]
            ]
        ]


viewTitle : Model -> Html msg
viewTitle { title } =
    Html.styled Html.h1
        [ Css.color Theme.secondary
        , Css.backgroundColor Theme.primary
        , Css.textAlign Css.center
        , Css.margin4 zero zero (px 20) zero
        , Css.padding2 (px 40) (px 12)
        , Css.fontSize (px 24)
        ]
        []
        [ Html.text <| "Typewriter Is "
        , Html.styled Html.em
            [ Css.color Theme.accent ]
            []
            [ Html.text <| Typewriter.view title ]
        ]


type Msg
    = TitleMsg Typewriter.Msg
    | BasicMsg Basic.Msg
    | TimesMsg Times.Msg
    | DelayMsg Delay.Msg
    | JitterMsg Jitter.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TitleMsg typewriterMsg ->
            let
                ( title, cmd ) =
                    Typewriter.update typewriterMsg model.title
            in
            ( { model | title = title }, Cmd.map TitleMsg cmd )

        BasicMsg basicMsg ->
            let
                ( basic, cmd ) =
                    Basic.update basicMsg model.basic
            in
            ( { model | basic = basic }, Cmd.map BasicMsg cmd )

        TimesMsg timesMsg ->
            let
                ( times, cmd ) =
                    Times.update timesMsg model.times
            in
            ( { model | times = times }, Cmd.map TimesMsg cmd )

        DelayMsg delayMsg ->
            let
                ( delay, cmd ) =
                    Delay.update delayMsg model.delay
            in
            ( { model | delay = delay }, Cmd.map DelayMsg cmd )

        JitterMsg jitterMsg ->
            let
                ( jitter, cmd ) =
                    Jitter.update jitterMsg model.jitter
            in
            ( { model | jitter = jitter }, Cmd.map JitterMsg cmd )



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> init
        , view = view >> Html.toUnstyled
        , update = update
        , subscriptions = \_ -> Sub.none
        }
