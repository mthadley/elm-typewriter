module Layout exposing (example)

import Css exposing (num, px, zero)
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes exposing (disabled)
import Html.Styled.Events exposing (onClick)
import Theme


type alias ExampleConfig msg =
    { text : String
    , buttons : List (ButtonConfig msg)
    , code : String
    , title : String
    }


example : ExampleConfig msg -> Html msg
example config =
    Html.styled Html.section
        [ Css.marginBottom (px 20)
        ]
        []
        [ Html.styled Html.h2
            [ Css.fontSize (px 20) ]
            []
            [ Html.text config.title ]
        , Html.styled Html.div
            [ Css.backgroundColor Theme.lighter
            , Css.padding2 (px 12) (px 6)
            , Css.color Theme.secondary
            , Theme.borderRadius
            ]
            []
            [ Html.text <| ">> " ++ config.text ]
        , Html.styled Html.div
            [ Css.margin4 (px -5) zero (px 12) zero ]
            []
            (List.map viewButton config.buttons)
        , Html.styled Html.pre
            [ Css.textOverflow Css.ellipsis
            , Css.overflow Css.hidden
            , Theme.borderRadius
            ]
            []
            [ Html.code []
                [ Html.text config.code ]
            ]
        ]


type alias ButtonConfig msg =
    { onClick : msg
    , label : String
    , disabled : Bool
    }


viewButton : ButtonConfig msg -> Html msg
viewButton config =
    Html.styled Html.button
        [ Css.border3 (px 2) Css.solid Theme.lighter
        , Theme.borderRadius
        , Css.color Css.inherit
        , Css.backgroundColor Css.inherit
        , Css.fontFamily Css.inherit
        , Css.fontSize (px 12)
        , Css.padding2 (px 4) (px 12)
        , Css.disabled
            [ Css.opacity (num 0.5)
            ]
        ]
        [ onClick config.onClick
        , disabled config.disabled
        ]
        [ Html.text config.label ]
