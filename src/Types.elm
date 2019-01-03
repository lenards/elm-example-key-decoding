module Types exposing (KeyValue(..), Keys, Model, Msg(..))


type KeyValue
    = Character Char
    | Control String


type alias Keys =
    List KeyValue


type Msg
    = AddKey KeyValue
    | NoOp


type alias Model =
    { keys : Keys
    }
