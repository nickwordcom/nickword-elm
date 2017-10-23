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


userIsActive : User -> Bool
userIsActive user =
    if user.status == Active then
        True
    else
        False


userIsUnknown : User -> Bool
userIsUnknown user =
    if user.status == Unknown then
        True
    else
        False


userIsLoading : User -> Bool
userIsLoading user =
    if user.status == Loading then
        True
    else
        False
