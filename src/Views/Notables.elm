module Views.Notables exposing (..)

import Html exposing (Html, div, h1, h2, h3, text)
import Html.Attributes exposing (class)
import Json.Decode as D
import Session exposing (Session)
import Tailwind as Tw


type alias Model =
    { session : Session
    }


type alias Msg =
    ()


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session }
    , Cmd.none
    )


view : Model -> { title : String, content : Html Msg }
view _ =
    { title = "Notable Members"
    , content =
        div [ Tw.bg_opacity_80, Tw.bg_gray_700, Tw.w_full, Tw.flex_1, Tw.text_white, Tw.flex, Tw.flex_col ]
            [ div [ Tw.ml_16, Tw.mr_16, Tw.mb_20 ]
                [ h1 [ Tw.text_6xl, class "montserrat", Tw.mt_2, Tw.py_2, Tw.text_center ] [ text "Notable Members" ]
                , h2 [ Tw.text_2xl, Tw.py_2, Tw.font_titillium, Tw.text_center ] [ text "Members on this list have made notable contributions to the success of our community!" ]
                , category "Server Administrators"
                , category "Server Moderators"
                ]
            ]
    }


category body =
    h3 [ class "montserrat", Tw.text_2xl, Tw.py_2, Tw.mt_2 ] [ text body ]


toSession =
    .session


type alias NotableData =
    { admins : List Person
    , moderators : List Person
    }


decodeNotableData : D.Decoder NotableData
decodeNotableData =
    D.map2 NotableData
        (D.field "admins" decodePeople)
        (D.field "moderators" decodePeople)


decodePeople : D.Decoder (List Person)
decodePeople =
    let
        decodePerson =
            D.map2 Person (D.field "name" D.string) (D.field "image-url" D.string)
    in
    D.list decodePerson


type alias Person =
    { name : String
    , imageUrl : String
    }
