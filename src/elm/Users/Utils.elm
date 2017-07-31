module Users.Utils exposing (..)

import Users.Models exposing (..)


checkUserJWT : Maybe String -> User
checkUserJWT localJWT =
    case localJWT of
        Just jwt ->
            activateUser jwt

        Nothing ->
            userInitialModel


activateUser : UserToken -> User
activateUser token =
    { status = Active, jwt = token }
