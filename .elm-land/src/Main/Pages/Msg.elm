module Main.Pages.Msg exposing (Msg(..))

import Pages.Home_
import Pages.Learning
import Pages.Learning.Resource_
import Pages.Rules
import Pages.NotFound_


type Msg
    = Home_ Pages.Home_.Msg
    | Learning Pages.Learning.Msg
    | Learning_Resource_ Pages.Learning.Resource_.Msg
    | Rules Pages.Rules.Msg
    | NotFound_ Pages.NotFound_.Msg
