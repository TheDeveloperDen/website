module Main.Pages.Model exposing (Model(..))

import Pages.Home_
import Pages.Learning
import Pages.Learning.Resource_
import Pages.Rules
import Pages.NotFound_
import View exposing (View)


type Model
    = Home_ Pages.Home_.Model
    | Learning Pages.Learning.Model
    | Learning_Resource_ { resource : String } Pages.Learning.Resource_.Model
    | Rules Pages.Rules.Model
    | NotFound_ Pages.NotFound_.Model
    | Redirecting_
    | Loading_
