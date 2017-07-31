module Users.Models exposing (..)


type UserStatus
    = Unknown
    | Loading
    | Active


type alias UserToken =
    String


type alias User =
    { status : UserStatus
    , jwt : UserToken
    }


userInitialModel : User
userInitialModel =
    { status = Unknown
    , jwt = ""
    }
