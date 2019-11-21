port module Session exposing (Session(..), requestSessionData, receiveSessionData, subscriptions, Event(..))


type Session
    = Guest
    | LoggedIn String

type Event
    = OnSessionChanged (Maybe String)

port requestSessionData : () -> Cmd msg
port receiveSessionData : ((Maybe String) -> msg) -> Sub msg

subscriptions : Sub Event
subscriptions =
    receiveSessionData OnSessionChanged