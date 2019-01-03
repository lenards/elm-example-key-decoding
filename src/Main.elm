module Main exposing (main)

import Browser
import Browser.Events exposing (onKeyDown)
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode
import Types exposing (KeyValue(..), Model, Msg(..))
import Utils exposing (keyDecoder)


init : () -> ( Model, Cmd Msg )
init _ =
    ( { keys = [] }, Cmd.none )



{- If you're looking for key inputs, like Modifier keys [0], you will
   not see them if you're using `onKeyPress`, which the documentation has
   a kind notes about [1]. That's why `onKeyDown` is used here.

   [0] https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values#Modifier_keys
   [1] https://package.elm-lang.org/packages/elm/browser/1.0.1/Browser-Events#onKeyPress
-}


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onKeyDown (Decode.map AddKey keyDecoder)
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddKey value ->
            ( { model | keys = value :: model.keys }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Key Decoding Example" ]
        , div []
            [ text "Press keys on the keyboard to see what is decoded:"
            , div
                [ style "border" "3px solid #60B5CC"
                , style "padding" "5px"
                ]
                [ ul [] (model.keys |> List.map renderKey) ]
            ]
        ]


renderKey : KeyValue -> Html Msg
renderKey keyValue =
    case keyValue of
        Character char ->
            li [] [ text ("Character:  " ++ String.fromChar char) ]

        Control str ->
            li [] [ text ("ControlKey:   " ++ str) ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
