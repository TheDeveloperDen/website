module Viewer exposing (Viewer, avatar, cred, decoder, minPasswordChars, store, username)

{-| The logged-in user currently viewing this page. It stores enough data to
be able to render the menu bar (username and avatar), along with Cred so it's
impossible to have a Viewer if you aren't logged in.
-}

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)



-- TYPES


type Username
    = Username String


type Cred
    = Cred Username String


type Viewer
    = Viewer Cred



-- INFO


cred : Viewer -> Cred
cred (Viewer val) =
    val


username : Viewer -> Username
username (Viewer (Cred val _)) =
    val


{-| Passwords must be at least this many characters long!
-}
minPasswordChars : Int
minPasswordChars =
    6



-- SERIALIZATION


decoder : Decoder (Cred -> Viewer)
decoder =
    Decode.map Viewer <|
        Decode.field "username" Avatar.decoder



--
--store : Viewer -> Cmd msg
--store (Viewer avatarVal credVal) =
--    Api.storeCredWith
--        credVal
--        avatarVal
