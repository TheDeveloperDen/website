module Layouts exposing (..)

import Layouts.Global


type Layout msg
    = Global Layouts.Global.Props


map : (msg1 -> msg2) -> Layout msg1 -> Layout msg2
map fn layout =
    case layout of
        Global data ->
            Global data
