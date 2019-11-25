port module Session exposing (Session(..), requestSessionData, receiveSessionData, deleteSessionData, subscriptions, Event(..))


type Session
    = Guest
    | LoggedIn String

type Event
    = OnSessionChanged (Maybe String)

port requestSessionData : () -> Cmd msg
port receiveSessionData : ((Maybe String) -> msg) -> Sub msg
port deleteSessionData : () -> Cmd msg

subscriptions : Sub Event
subscriptions =
    receiveSessionData OnSessionChanged