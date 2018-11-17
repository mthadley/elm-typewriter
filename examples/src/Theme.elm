module Theme exposing
    ( accent
    , borderRadius
    , lighter
    , primary
    , secondary
    )

import Css exposing (Color, hex, px)


secondary : Color
secondary =
    hex "F5F0E6"


primary : Color
primary =
    hex "383735"


lighter : Color
lighter =
    hex "62615D"


accent : Color
accent =
    hex "FF5050"


borderRadius : Css.Style
borderRadius =
    Css.borderRadius (px 2)
