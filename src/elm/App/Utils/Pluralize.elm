module App.Utils.Pluralize exposing (..)

{-| Given a number, a singular string, and a plural string, returns the number
followed by a space, followed by either the singular string if the number was 1,
or the plural string otherwise.
pluralize "elf" "elves" 2 == "2 elves"
pluralize "elf" "elves" 1 == "1 elf"
pluralize "elf" "elves" 0 == "0 elves"
-}


pluralize : String -> String -> number -> String
pluralize singular plural count =
    if count == 1 then
        "1 " ++ singular
    else
        toString count ++ " " ++ plural



{-
   The draft Ukrainian (uk) plural rules are:
     one: 1, 21, 31, 41, 51, 61...
     few: 2-4, 22-24, 32-34...
     many: 0, 5-20, 25-30, 35-40...;

-}


pluralizeUk : String -> String -> String -> Int -> String
pluralizeUk one few many count =
    let
        modulo10 =
            count % 10

        modulo100 =
            count % 100

        countStr =
            toString count ++ " "
    in
    if modulo10 == 1 && modulo100 /= 11 then
        countStr ++ one
    else if (modulo10 == 2 || modulo10 == 3 || modulo10 == 4) && not (modulo100 == 12 || modulo100 == 13 || modulo100 == 14) then
        countStr ++ few
    else if modulo10 == 0 || (modulo10 == 5 || modulo10 == 6 || modulo10 == 7 || modulo10 == 8 || modulo10 == 9) || (modulo100 == 11 || modulo100 == 12 || modulo100 == 13 || modulo100 == 14) then
        countStr ++ many
    else
        countStr ++ many



{-
   The draft Russian (ru) plural rules are:
     - same as Ukrainian
-}


pluralizeRu : String -> String -> String -> Int -> String
pluralizeRu one few many count =
    pluralizeUk one few many count



-- Spanish (es) plural rules:


pluralizeEs : String -> String -> number -> String
pluralizeEs singular plural count =
    if count == 1 then
        "1 " ++ singular
    else
        toString count ++ " " ++ plural
