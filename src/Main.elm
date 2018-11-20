module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes as Attrs exposing (..)
import Html.Events exposing (..)


main =
    Browser.sandbox { init = init, view = view, update = update }


total =
    600


defaultHours =
    20


costPerMonth =
    2000


type alias Model =
    { hoursPerMonth : Int }


type Msg
    = HoursChanged String
    | ManualChange String


init : Model
init =
    { hoursPerMonth = defaultHours }


update : Msg -> Model -> Model
update msg model =
    case msg of
        HoursChanged hours ->
            { model | hoursPerMonth = Maybe.withDefault 0 (String.toInt hours) }

        ManualChange value ->
            { model | hoursPerMonth = Maybe.withDefault defaultHours (String.toInt value) }


renderTotal : String -> Int -> Html Msg
renderTotal label number =
    p [] [ text (String.fromInt number ++ " " ++ label) ]


view : Model -> Html Msg
view model =
    let
        hours =
            String.fromInt model.hoursPerMonth

        totalWeeks =
            total // model.hoursPerMonth

        totalMonth =
            totalWeeks // 4

        totalCost =
            costPerMonth * totalMonth
    in
    div []
        [ h2 [] [ text "How much would it cost ? " ]
        , input
            [ type_ "range", Attrs.min "10", Attrs.max "60", value hours, Html.Events.onInput HoursChanged ]
            []
        , label [] [ text hours ]
        , h2 [] [ text "The program total:" ]
        , renderTotal "weeks" totalWeeks
        , renderTotal "months" totalMonth
        , renderTotal "$" totalCost
        , input [ type_ "text", onInput ManualChange ] []
        ]
